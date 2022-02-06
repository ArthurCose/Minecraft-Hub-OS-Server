local Blocks = require("scripts/minecraft/data/blocks")
local BlockLoot = require("scripts/minecraft/data/block_loot")
local InventoryUtil = require("scripts/minecraft/inventory_util")

local Player = {}

local Menu = {
  ACTIONS = 0,
  INVENTORY = 1,
  CHEST = 2,
  CHEST_INVENTORY_SUBMENU = 3,
  COLOR = { r = 139, g = 139, b = 139 }
}

local Action = {
  PUNCH = 0,
  JUMP = 1,
  ITEM = 2,
  INTERACT = 3,
}

function Player:new(player_id)
  local player = {
    id = player_id,
    instance = nil,
    avatar = {},
    menus = {}, -- { id, (menu specific) }
    items = { -- { id, count }[]
    -- starting items
      { id = "COBBLESTONE", count = 8 }
    },
    action = Action.PUNCH,
    selected_item = nil,
    x = 0,
    y = 0,
    z = 0,
    int_x = 0,
    int_y = 0,
    int_z = 0,
    spawned = false,
    changing_z = false
  }

  setmetatable(player, self)
  self.__index = self

  return player
end

function Player:tick()
  self:update_menu()

  if self.spawned and not self.changing_z and self.instance.world:get_block(self.int_x, self.int_y, self.int_z - 2) == Blocks.AIR then
    self:fall_towards(self.x, self.y)
  end
end

function Player:handle_player_join()
  self.spawned = true

  local pos = Net.get_player_position(self.id)
  self:handle_player_move(pos.x, pos.y, pos.z)
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
    self:open_menu()
    return
  end

  if self.action == Action.JUMP then
    self:try_jump_up(x, y, z)
  elseif self.action == Action.PUNCH then
    self:try_break_block(x, y, z)
  elseif self.action == Action.ITEM then
    self:try_place_block(x, y, z)
  elseif self.action == Action.INTERACT then
    self:try_interact(x, y, z)
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
    return true
  end

  return false
end

function Player:try_place_block(x, y, z)
  if not self.selected_item then
    -- nothing to place
    return
  end

  local block = Blocks[self.selected_item.id]

  if not block then
    -- not placeable
    return
  end

  x = math.floor(x)
  y = math.floor(y)
  z = math.floor(z)

  local world = self.instance.world

  -- place a block below
  local floor_id = world:get_block(x, y, z - 2)

  if floor_id == Blocks.AIR then
    return place_block(self, x, y, z - 2)
  end

  -- place a block at feet
  local feet_id = world:get_block(x, y, z)

  if feet_id == Blocks.AIR then
    return place_block(self, x, y, z)
  end

  -- place a block at head
  local head_id = world:get_block(x, y, z + 2)

  if head_id == Blocks.AIR then
    return place_block(self, x, y, z + 2)
  end

  return false
end

local function break_block(player, x, y, z)
  local block_id = player.instance.world:get_block(x, y, z)

  if block_id == Blocks.BEDROCK or block_id == Blocks.AIR then
    return false
  end

  if player.instance.world:set_block(x, y, z, Blocks.AIR) then
    local loot = BlockLoot[block_id]
    InventoryUtil.add_item(player.items, loot[math.random(#loot)])
    player:lockout()
    return true
  end

  return false
end

function Player:try_break_block(x, y, z)
  local float_x = x
  local float_y = y

  x = math.floor(x)
  y = math.floor(y)
  z = math.floor(z)

  local world = self.instance.world

  -- break the block at head
  local head_id = world:get_block(x, y, z + 2)

  if head_id ~= Blocks.AIR then
    return break_block(self, x, y, z + 2)
  end

  -- break the block at feet
  local feet_id = world:get_block(x, y, z)

  if feet_id ~= Blocks.AIR then
    return break_block(self, x, y, z)
  end

  -- break the block below
  local floor_id = world:get_block(x, y, z - 2)

  if floor_id ~= Blocks.AIR then
    return break_block(self, x, y, z - 2)
  end

  -- try jumping down
  if head_id == Blocks.AIR and feet_id == Blocks.AIR and floor_id == Blocks.AIR then
    self:fall_towards(float_x, float_y)
  end
end

function Player:try_jump_up(x, y, z)
  local int_x = math.floor(x)
  local int_y = math.floor(y)
  local int_z = math.floor(z)

  local world = self.instance.world

  -- try jumping
  local feet_id = world:get_block(int_x, int_y, int_z)
  local head_id = world:get_block(int_x, int_y, int_z + 2)
  local ceiling_id = world:get_block(int_x, int_y, int_z + 4)

  if feet_id ~= Blocks.AIR and head_id == Blocks.AIR and ceiling_id == Blocks.AIR then
    self:animate_jump_up(self.id, x, y, int_z + 2)
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

function Player:animate_jump_up(player_id, x, y, z)
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

  self.changing_z = true

  Async.sleep(total_time).and_then(function()
    self.changing_z = false
  end)

  return total_time
end

function Player:animate_jump_down(player_id, x, y, z)
  local z_diff = math.abs(z - self.int_z)

  local start_time = .2
  local remaining_time = (z_diff) / 2 * .1

  Net.animate_player_properties(player_id, {
    {
      properties = {
        { property = "X", ease = "Out", value = x },
        { property = "Y", ease = "Out", value = y },
      },
      duration = start_time
    },
    {
      properties = {
        { property = "Z", ease = "In", value = z }
      },
      duration = remaining_time
    }
  })

  local total_time = start_time + remaining_time

  self.changing_z = true

  Async.sleep(total_time).and_then(function()
    self.changing_z = false
  end)

  return total_time
end

function Player:fall_towards(x, y)
  local int_x = math.floor(x)
  local int_y = math.floor(y)

  local land_z = 0
  local world = self.instance.world

  for test_z = self.int_z - 4, 0, -2 do
    if world:get_block(int_x, int_y, test_z) ~= Blocks.AIR then
      land_z = test_z + 2
      break
    end
  end

  local time = self:animate_jump_down(self.id, x, y, land_z)

  Async.sleep(time).and_then(function()
    if land_z == 0 then
      -- return to spawn
      local spawn = Net.get_spawn_position(self.instance.id)
      Net.teleport_player(self.id, true, spawn.x, spawn.y, spawn.z)

      self.changing_z = true
      Async.sleep(1).and_then(function()
        self.changing_z = false
      end)
    end
  end)
end

function Player:try_interact(x, y, z)
  x = math.floor(x)
  y = math.floor(y)

  local world = self.instance.world
  local block_id = world:get_block(x, y, z)

  if block_id == Blocks.CHEST then
    local tile_entity = world:request_tile_entity(x, y, z)
    self:open_chest(tile_entity)
  end
end

function Player:open_menu()
  if #self.menus > 0 then
    return
  end

  local posts = {
    { id = "INVENTORY", read = true, title = "INVENTORY", author = "" },
    { id = "PUNCH", read = true, title = "PUNCH/FALL", author = "" },
    { id = "JUMP", read = true, title = "JUMP", author = "" },
    { id = "INTERACT", read = true, title = "INTERACT", author = "" },
  }

  Net.open_board(self.id, "Actions", Menu.COLOR, posts)
  self.menus[#self.menus+1] = { id = Menu.ACTIONS }
end

function Player:open_inventory()
  local posts = {
    { id = "CRAFT", read = true, title = "CRAFT", author = "" }
  }

  InventoryUtil.generate_item_posts(self.items, posts)

  Net.open_board(self.id, "Inventory", Menu.COLOR, posts)
  self.menus[#self.menus+1] = { id = Menu.INVENTORY }
end

function Player:open_chest(tile_entity)
  local posts = {
    { id = "INVENTORY", read = true, title = "INVENTORY", author = "" }
  }

  if not tile_entity.data.items then
    tile_entity.data.items = {}
  end

  InventoryUtil.generate_item_posts(tile_entity.data.items, posts)

  Net.open_board(self.id, "Chest", Menu.COLOR, posts)
  self.menus[#self.menus+1] = { id = Menu.CHEST, posts = posts, tile_entity = tile_entity }
end

function Player:open_chest_inventory_submenu(tile_entity)
  local posts = {}

  InventoryUtil.generate_item_posts(self.items, posts)

  Net.open_board(self.id, "Inventory", Menu.COLOR, posts)
  self.menus[#self.menus+1] = { id = Menu.CHEST_INVENTORY_SUBMENU, tile_entity = tile_entity, posts = posts }
end

function Player:update_menu()
  local current_menu = self.menus[#self.menus]

  if not current_menu then
    return
  end

  if current_menu.tile_entity and current_menu.tile_entity.deleted then
    -- block we're looking at was deleted
    self:close_menu()
    return
  end

  if current_menu.id == Menu.CHEST then
    InventoryUtil.sync_inventory_menu(self, current_menu.tile_entity.data.items, current_menu.posts, 1)
  elseif current_menu.id == Menu.CHEST_INVENTORY_SUBMENU then
    InventoryUtil.sync_inventory_menu(self, self.items, current_menu.posts, 0)
  end
end

function Player:handle_post_selection(post_id)
  local current_menu = self.menus[#self.menus]

  if not current_menu then
    return
  end

  if current_menu.id == Menu.ACTIONS then
    if post_id == "PUNCH" then
      self.action = Action.PUNCH
      self:close_menu()
    elseif post_id == "JUMP" then
      self.action = Action.JUMP
      self:close_menu()
    elseif post_id == "INVENTORY" then
      self:open_inventory()
    elseif post_id == "INTERACT" then
      self.action = Action.INTERACT
      self:close_menu()
    end
  elseif current_menu.id == Menu.INVENTORY then
    if post_id == "CRAFT" then
      Net.message_player(self.id, "Not yet available")
    else
      -- selecting an item
      for i, item in ipairs(self.items) do
        if item.id == post_id then
          self.selected_item = item
          self.action = Action.ITEM

          -- move to top
          table.remove(self.items, i)
          table.insert(self.items, 1, item)
          break
        end
      end

      self:close_menu()
    end
  elseif current_menu.id == Menu.CHEST then
    if current_menu.tile_entity.deleted then
      -- just exit the menu if the chest is gone
      self:close_menu()
    elseif post_id == "INVENTORY" then
      self:open_chest_inventory_submenu(current_menu.tile_entity)
    else
      -- take one item out of the chest
      local items = current_menu.tile_entity.data.items

      if InventoryUtil.remove_item(items, post_id) then
        InventoryUtil.add_item(self.items, post_id)
        self:update_menu()
      end
    end
  elseif current_menu.id == Menu.CHEST_INVENTORY_SUBMENU then
    if current_menu.tile_entity.deleted then
      -- just exit the menu if the chest is gone
      self:close_menu()
    else
      -- move one item into the chest
      local items = current_menu.tile_entity.data.items

      if InventoryUtil.remove_item(self.items, post_id) then
        InventoryUtil.add_item(items, post_id)
        self:update_menu()
      end
    end
  end
end

function Player:close_menu()
  Net.close_bbs(self.id)
  self.menus = {}
end

function Player:handle_board_close()
  self.menus[#self.menus] = nil
end

return Player
