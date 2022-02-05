local Blocks = require("scripts/minecraft/blocks")

local Player = {}

local Menu = {
  INVENTORY = 0,
  COLOR = { r = 139, g = 139, b = 139 }
}

function Player:new(player_id)
  local player = {
    id = player_id,
    instance = nil,
    avatar = {},
    menus = {},
    items = { -- { id, count }[]
    -- starting items
      { id = "COBBLESTONE", count = 8 }
    },
    selected_item = nil,
    x = 0,
    y = 0,
    z = 0,
    int_x = 0,
    int_y = 0,
    int_z = 0,
  }

  setmetatable(player, self)
  self.__index = self

  return player
end

function Player:handle_player_avatar_change(details)
  self.avatar = details
end

function Player:handle_player_move(x, y, z)
  self.x = x
  self.y = y
  self.z = z
  self.int_x = math.floor(x)
  self.int_y = math.floor(y)
  self.int_z = math.floor(z / self.instance.world.layer_diff) * self.instance.world.layer_diff

  if self.instance then
    self.instance:handle_player_move(self)
  end
end

function Player:handle_actor_interaction(other_id, button)
  if not self.instance then
    return
  end

  if not Net.is_bot(other_id) then
    return
  end

  local pos = Net.get_bot_position(other_id)

  self:handle_tile_interaction(pos.x, pos.y, pos.z, button)
end

function Player:handle_tile_interaction(x, y, z, button)
  if not self.instance then
    return
  end

  x = math.floor(x) + .5
  y = math.floor(y) + .5

  if button == 1 then
    self:open_inventory()
    return
  end

  if self.selected_item == nil then
    self:break_block(x, y, z)
  elseif Blocks[self.selected_item.id] then
    self:place_block(x, y, z)
  end
end

local function consume_item(player)
  local item = player.selected_item
  item.count = item.count - 1

  if item.count == 0 then
    player.selected_item = nil

    for i, inventory_item in ipairs(player.items) do
      if inventory_item == item then
        table.remove(player.items, i)
        break
      end
    end
  end
end

local function place_block(player, x, y, z)
  local block = Blocks[player.selected_item.id]

  if player.instance.world:set_block(x, y, z, block) then
    consume_item(player)
    player:lockout()
  end
end

function Player:place_block(x, y, z)
  local block = Blocks[self.selected_item.id]

  if not block then
    return
  end

  local float_x = x
  local float_y = y

  x = math.floor(x)
  y = math.floor(y)
  z = math.floor(z)

  local world = self.instance.world

  -- place a block below
  local floor_id = world:get_block(x, y, z - 2)

  if floor_id == Blocks.AIR then
    place_block(self, x, y, z - 2)
    return
  end

  -- place a block at feet
  local feet_id = world:get_block(x, y, z)

  if feet_id == Blocks.AIR then
    place_block(self, x, y, z)
    return
  end

  -- try jumping
  local head_id = world:get_block(x, y, z + 2)
  local ceiling_id = world:get_block(x, y, z + 4)

  if head_id == Blocks.AIR and ceiling_id == Blocks.AIR then
    self:jump_up(self.id, float_x, float_y, z + 2)
    return
  end
end

local function break_block(player, x, y, z)
  local block_id = player.instance.world:get_block(x, y, z)

  if block_id == Blocks.BEDROCK or block_id == Blocks.AIR then
    return
  end

  if player.instance.world:set_block(x, y, z, Blocks.AIR) then
    local loot = Blocks.Drops[block_id]
    player:add_item(loot[math.random(#loot)])
  end

  player:lockout()
end

function Player:break_block(x, y, z)
  local float_x = x
  local float_y = y

  x = math.floor(x)
  y = math.floor(y)
  z = math.floor(z)

  local world = self.instance.world

  -- break the block at head
  local head_id = world:get_block(x, y, z + 2)

  if head_id ~= Blocks.AIR then
    break_block(self, x, y, z + 2)
    return
  end

  -- break the block at feet
  local feet_id = world:get_block(x, y, z)

  if feet_id ~= Blocks.AIR then
    break_block(self, x, y, z)
    return
  end

  -- break the block below
  local floor_id = world:get_block(x, y, z - 2)

  if floor_id ~= Blocks.AIR then
    break_block(self, x, y, z - 2)
    return
  end

  -- try jumping down
  local next_floor_id = world:get_block(x, y, z - 4)

  if head_id == Blocks.AIR and feet_id == Blocks.AIR and floor_id == Blocks.AIR and next_floor_id ~= Blocks.AIR then
    self:jump_down(self.id, float_x, float_y, z - 2)
    return
  end
end

function Player:lockout(time)
  if time == nil then
    time = .3
  end

  Net.lock_player_input(self.id)
  Async.sleep(time).and_then(function()
    Net.unlock_player_input(self.id)
  end)
end

function Player:jump_up(player_id, x, y, z)
  local total_time = .25
  Net.animate_player_properties(player_id, {
    {
      properties = {
        { property = "Z", ease = "Out", value = z + .5 }
      },
      duration = total_time * 2 / 3
    },
    {
      properties = {
        { property = "X", ease = "Linear", value = x },
        { property = "Y", ease = "Linear", value = y },
        { property = "Z", ease = "In", value = z }
      },
      duration = total_time * 1 / 3
    }
  })
end

function Player:jump_down(player_id, x, y, z)
  local total_time = .2
  Net.animate_player_properties(player_id, {
    {
      properties = {
        { property = "X", ease = "Out", value = x },
        { property = "Y", ease = "Out", value = y },
        { property = "Z", ease = "In", value = z }
      },
      duration = total_time
    }
  })
end

function Player:add_item(item_id)
  if item_id == nil then
    return
  end

  for _, item in ipairs(self.items) do
    if item.id == item_id then
      item.count = item.count + 1
      return
    end
  end

  self.items[#self.items+1] = {
    id = item_id,
    count = 1
  }
end

function Player:open_inventory()
  self.menus[#self.menus+1] = Menu.INVENTORY

  local posts = {}

  for _, item in ipairs(self.items) do
    posts[#posts+1] = { id = item.id, read = true, title = item.id, author = item.count }
  end

  Net.open_board(self.id, "Inventory", Menu.COLOR, posts)
end

function Player:handle_post_selection(post_id)
  local current_menu = self.menus[#self.menus]

  if current_menu == Menu.INVENTORY then
    for i, item in ipairs(self.items) do
      if item.id == post_id then
        self.selected_item = item

        -- move to top
        table.remove(self.items, i)
        table.insert(self.items, 1, item)
        break
      end
    end

    self:close_menu()
  end
end

function Player:close_menu()
  Net.close_bbs(self.id)
  self.menus[#self.menus] = nil
end

function Player:handle_board_close()
  local current_menu = self.menus[#self.menus]

  if current_menu == Menu.INVENTORY then
    self.selected_item = nil
  end

  self.menus[#self.menus] = nil
end

return Player
