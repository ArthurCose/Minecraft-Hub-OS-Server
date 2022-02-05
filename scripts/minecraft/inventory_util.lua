-- inventory/items format = { id: string, count: int }

local InventoryUtil = {}

-- defaults to adding one item
function InventoryUtil.add_item(items, item_id, count)
  if item_id == nil then
    return
  end

  count = count or 1

  for _, item in ipairs(items) do
    if item.id == item_id then
      item.count = item.count + count
      return
    end
  end

  items[#items+1] = {
    id = item_id,
    count = count
  }
end

-- defaults to removing one item
function InventoryUtil.remove_item(items, item_id, count)
  count = count or 1

  for i, item in ipairs(items) do
    if item.id == item_id then
      item.count = item.count - count

      if item.count == 0 then
        table.remove(items, i)
      end

      return true
    end
  end

  return false
end

function InventoryUtil.generate_item_posts(items, posts)
  for _, item in ipairs(items) do
    posts[#posts+1] = { id = item.id, read = true, title = item.id, author = item.count }
  end
end

local function find_matching_post_index(posts, item, start_index)
  for i = start_index, #posts do
    if posts[i].id == item.id then
      return i
    end
  end

  return -1
end

function InventoryUtil.sync_inventory_menu(player, items, posts, start_offset)
  local pre_first_post_id = posts[start_offset] and posts[start_offset].id
  local last_post_id = pre_first_post_id
  local last_post_index = start_offset
  local post_index = 1 + start_offset

  for item_index, item in ipairs(items) do
    local new_post_index = find_matching_post_index(posts, item, post_index)

    if new_post_index == -1 then
      -- append from here to the end
      local new_posts = {}

      for i = item_index, #items do
        local next_item = items[i]

        local post = { id = next_item.id, read = true, title = next_item.id, author = next_item.count }
        new_posts[#new_posts+1] = post
        posts[#posts+1] = post
      end

      last_post_index = #posts
      post_index = last_post_index
      Net.append_posts(player.id, new_posts, last_post_id)
      break
    end

    local posts_between_last = new_post_index - last_post_index - 1

    if posts_between_last > 0 then
      -- remove posts
      for _ = 1, posts_between_last do
        Net.remove_post(player.id, posts[last_post_index + 1].id)
        table.remove(posts, last_post_index + 1)
      end
      new_post_index = new_post_index - posts_between_last
    end

    last_post_index = new_post_index
    post_index = new_post_index
    local post = posts[post_index]

    if post.author ~= item.count then
      -- update count
      post.author = item.count
      Net.prepend_posts(player.id, { { id = "temp", read = true } }, post.id)
      Net.remove_post(player.id, post.id)
      Net.append_posts(player.id, { post }, "temp")
      Net.remove_post(player.id, "temp")
    end

    last_post_id = post.id
  end

  local remaining_posts = #posts - last_post_index

  for _ = 1, remaining_posts do
    Net.remove_post(player.id, posts[last_post_index + 1].id)
    table.remove(posts, last_post_index + 1)
  end
end

return InventoryUtil
