local InventoryUtil = require("scripts/minecraft/inventory_util")
local CraftingUtil = {}

function CraftingUtil.generate_recipe_posts(recipes, items, posts)
  for recipe_index, recipe in ipairs(recipes) do
    local matches = true

    for _, required_item in ipairs(recipe.required) do
      if not InventoryUtil.has_item(items, required_item.id, required_item.count) then
        matches = false
        break
      end
    end

    if matches then
      posts[#posts+1] = { id = recipe_index, read = true, title = recipe.result.id, author = recipe.result.count }
    end
  end
end

function CraftingUtil.craft(recipes, items, post_id)
  local recipe = recipes[tonumber(post_id)]

  -- take required items
  for _, item in ipairs(recipe.required) do
    InventoryUtil.remove_item(items, item.id, item.count)
  end

  -- give the result
  InventoryUtil.add_item(items, recipe.result.id, recipe.result.count)

  -- move the item to the top of the list
  for i, item in ipairs(items) do
    if item.id == recipe.result.id then
      table.remove(items, i)
      table.insert(items, 1, item)
      break
    end
  end
end

return CraftingUtil
