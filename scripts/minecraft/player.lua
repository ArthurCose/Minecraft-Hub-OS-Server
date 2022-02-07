local Blocks = require("scripts/minecraft/data/blocks")
local BlockLoot = require("scripts/minecraft/data/block_loot")
local Liquids = require("scripts/minecraft/data/liquids")
local Tags = require("scripts/minecraft/data/tags")
local NoCollision = require("scripts/minecraft/data/no_collision")
local MenuColors = require("scripts/minecraft/menu/menu_colors")
local PrimaryMenu = require("scripts/minecraft/menu/primary_menu")
local CraftingMenu = require("scripts/minecraft/menu/crafting_menu")
local CraftingRecipes = require("scripts/minecraft/data/crafting_recipes")
local ChestMenu = require("scripts/minecraft/menu/chest_menu")
local InventoryUtil = require("scripts/minecraft/inventory_util")
local PlayerActions = require("scripts/minecraft/player_actions")
local includes = require("scripts/libs/includes")

local Player = {}

function Player:new(player_id)
  local player = {
    id = player_id,
    instance = nil,
    avatar = {},
    menus = {}, -- { id, (menu specific) }
    items = { -- { id, count }[]
    -- starting items
      { id = "OAK_SAPLING", count = 1 },
      { id = "COBBLESTONE", count = 8 },
      { id = "DIRT", count = 16 }
    },
    action = PlayerActions.PUNCH,
    selected_item = nil,
    x = 0,
    y = 0,
    z = 0,
    int_x = 0,
    int_y = 0,
    int_z = 0,
    spawned = false,
    changing_z = false,
    textbox_promise_resolvers = {}
  }

  setmetatable(player, self)
  self.__index = self

  return player
end

function Player:tick()
  self:update_menu()

  if not self.spawned or self.changing_z then
    return
  end

  local world = self.instance.world

  local block_below_id = world:get_block(self.int_x, self.int_y, self.int_z - 2)

  if includes(NoCollision, block_below_id) and not includes(Liquids.Full, block_below_id) then
    self:fall_towards(self.x, self.y)
  end

  if includes(Liquids.Lava, world:get_block(self.int_x, self.int_y, self.int_z)) then
    self:respawn()
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
    if #self.menus == 0 then
      self:open_menu(PrimaryMenu:new(self))
    end
    return
  end

  if self.action == PlayerActions.JUMP then
    self:try_jump_up(x, y, z)
  elseif self.action == PlayerActions.PUNCH then
    self:try_break_block(x, y, z)
  elseif self.action == PlayerActions.ITEM then
    self:try_place_block(x, y, z)
  elseif self.action == PlayerActions.INTERACT then
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

function get_block_direction_suffix(player, int_x, int_y)
  if player.int_x > int_x then
    return "_E"
  elseif player.int_y > int_y then
    return "_N"
  elseif player.int_x < int_x then
    return "_W"
  elseif player.int_y < int_y then
    return "_S"
  end

  -- pick a nice direction in case there's no directionless version
  return "_N"
end

local function place_block(player, x, y, z)
  local direction_suffix = get_block_direction_suffix(player, x, y)
  local block_id = Blocks[player.selected_item.id .. direction_suffix] or Blocks[player.selected_item.id]

  local world = player.instance.world

  if (includes(NoCollision, block_id) or not world:has_player_at(x, y, z)) and world:set_block(x, y, z, block_id) then
    if includes(Tags["#signs"], player.selected_item.id) then
      local tile_entity = world:request_tile_entity(x, y, z)
      player:prompt(17 * 3).and_then(function(response)
        tile_entity.data.text = response
      end)
    end

    consume_item(player)
    player:lockout()
    return true
  end

  return false
end

function Player:try_place_block(x, y, z)
  if not self.selected_item then
    -- nothing to place
    return false
  end

  x = math.floor(x)
  y = math.floor(y)
  z = math.floor(z)

  local direction_suffix = get_block_direction_suffix(self, x, y)
  local block = Blocks[self.selected_item.id .. direction_suffix] or Blocks[self.selected_item.id]

  if not block then
    -- not placeable
    return false
  end

  local world = self.instance.world

  -- place a block below
  local floor_id = world:get_block(x, y, z - 2)

  if floor_id == Blocks.AIR or includes(Liquids.Flowing, floor_id) then
    return place_block(self, x, y, z - 2)
  end

  -- place a block at feet
  local feet_id = world:get_block(x, y, z)

  if feet_id == Blocks.AIR or includes(Liquids.Flowing, feet_id) then
    return place_block(self, x, y, z)
  end

  -- place a block at head
  local head_id = world:get_block(x, y, z + 2)

  if head_id == Blocks.AIR or includes(Liquids.Flowing, head_id) then
    return place_block(self, x, y, z + 2)
  end

  return false
end

local function break_block(player, x, y, z)
  local block_id = player.instance.world:get_block(x, y, z)

  if block_id == Blocks.BEDROCK or block_id == Blocks.AIR or includes(Liquids.All, block_id) then
    return false
  end

  if player.instance.world:set_block(x, y, z, Blocks.AIR) then
    local loot = BlockLoot[block_id]

    if #loot > 0 then
      InventoryUtil.add_item(player.items, loot[math.random(#loot)])
    end

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
  local can_jump_through_floor = floor_id == Blocks.AIR or includes(Liquids.All, floor_id)

  if not can_jump_through_floor then
    return break_block(self, x, y, z - 2)
  end

  -- try jumping down
  if head_id == Blocks.AIR and feet_id == Blocks.AIR and can_jump_through_floor then
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

  if (feet_id ~= Blocks.AIR and not includes(Liquids.All, feet_id)) and head_id == Blocks.AIR and ceiling_id == Blocks.AIR then
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
    local block_id = world:get_block(int_x, int_y, test_z)

    if not includes(NoCollision, block_id) or includes(Liquids.Full, block_id) then
      land_z = test_z + 2
      break
    end
  end

  local time = self:animate_jump_down(self.id, x, y, land_z)

  Async.sleep(time).and_then(function()
    if land_z == 0 then
      self:respawn()
    end
  end)
end

function Player:respawn()
  local spawn = Net.get_spawn_position(self.instance.id)
  Net.teleport_player(self.id, true, spawn.x, spawn.y, spawn.z)

  self.changing_z = true
  Async.sleep(1).and_then(function()
    self.changing_z = false
  end)
end

function Player:try_interact(x, y, z)
  x = math.floor(x)
  y = math.floor(y)

  local world = self.instance.world

  for i = 0, 1 do
    local test_z = z + i * world.layer_diff
    local block_id = world:get_block(x, y, test_z)

    if block_id == Blocks.CRAFTING_TABLE then
      self:open_menu(CraftingMenu:new(self, "Crafting Table", MenuColors.CRAFTING_TABLE_COLOR, CraftingRecipes.CraftingTable))
      break
    elseif block_id == Blocks.FURNACE or block_id == Blocks.FURNACE_E or block_id == Blocks.FURNACE_N then
      self:open_menu(CraftingMenu:new(self, "Furnace", MenuColors.FURNACE_COLOR, CraftingRecipes.Furnace))
      break
    elseif block_id == Blocks.CHEST or block_id == Blocks.CHEST_E or block_id == Blocks.CHEST_N then
      local tile_entity = world:request_tile_entity(x, y, test_z)
      self:open_menu(ChestMenu:new(self, tile_entity))
      break
    elseif block_id == Blocks.OAK_SIGN_N or block_id == Blocks.OAK_SIGN_S or block_id == Blocks.OAK_SIGN_E or block_id == Blocks.OAK_SIGN_W then
      local tile_entity = world:request_tile_entity(x, y, test_z)
      self:message(tile_entity.data.text)
      break
    end
  end
end

function Player:open_menu(menu)
  self.menus[#self.menus+1] = menu
  menu:open()
end

function Player:update_menu()
  local current_menu = self.menus[#self.menus]

  if not current_menu then
    return
  end

  current_menu:update()
end

function Player:handle_post_selection(post_id)
  local current_menu = self.menus[#self.menus]

  if not current_menu then
    return
  end

  current_menu:handle_selection(post_id)
end

function Player:close_menus()
  Net.close_bbs(self.id)
  self.menus = {}
end

function Player:handle_board_close()
  self.menus[#self.menus] = nil
end

-- textbox handling taken from the liberation server --

local function create_textbox_promise(self)
  if self.disconnected then
    return Async.create_promise(function(resolve)
      resolve()
    end)
  end

  return Async.create_promise(function(resolve)
    self.textbox_promise_resolvers[#self.textbox_promise_resolvers+1] = resolve
  end)
end

-- all messages to this player should be made through this class
function Player:message(message, texture_path, animation_path)
  Net.message_player(self.id, message, texture_path, animation_path)

  return create_textbox_promise(self)
end

-- all messages to this player should be made through this class
function Player:message_with_mug(message)
  return self:message(message, self.avatar.texture_path, self.avatar.animation_path)
end

-- all questions to this player should be made through this class
function Player:question(question, texture_path, animation_path)
  Net.question_player(self.id, question, texture_path, animation_path)

  return create_textbox_promise(self)
end

-- all questions to this player should be made through this class
function Player:question_with_mug(question)
  return self:question(question, self.avatar.texture_path, self.avatar.animation_path)
end

-- all quizzes to this player should be made through this class
function Player:quiz(a, b, c, texture_path, animation_path)
  Net.quiz_player(self.id, a, b, c, texture_path, animation_path)

  return create_textbox_promise(self)
end

-- all prompts to this player should be made through this class
function Player:prompt(character_limit, default_text)
  Net.prompt_player(self.id, character_limit, default_text)

  return create_textbox_promise(self)
end

-- will throw if a textbox is sent to the player using Net directly
function Player:handle_textbox_response(response)
  local resolve = table.remove(self.textbox_promise_resolvers, 1)
  resolve(response)
end

return Player
