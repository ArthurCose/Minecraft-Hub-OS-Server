local Blocks = require("scripts/minecraft/data/blocks")
local BlockLoot = require("scripts/minecraft/data/block_loot")
local Liquids = require("scripts/minecraft/data/liquids")
local Climbable = require("scripts/minecraft/data/climbable")
local Tags = require("scripts/minecraft/data/tags")
local NoCollision = require("scripts/minecraft/data/no_collision")
local MenuColors = require("scripts/minecraft/menu/menu_colors")
local PrimaryMenu = require("scripts/minecraft/menu/primary_menu")
local CraftingMenu = require("scripts/minecraft/menu/crafting_menu")
local CraftingRecipes = require("scripts/minecraft/data/crafting_recipes")
local ChestMenu = require("scripts/minecraft/menu/chest_menu")
local InventoryUtil = require("scripts/minecraft/inventory_util")
local PlayerActions = require("scripts/minecraft/player_actions")
local Direction = require("scripts/libs/direction")
local includes = require("scripts/libs/includes")

local Player = {}

function Player:new(player_id)
  local player = {
    id = player_id,
    instance = nil,
    avatar = {},
    menus = {}, -- { id, (menu specific) }
    last_menu_count = 1,
    items = {   -- { id, count }[]
      -- starting items
      { id = "OAK_SAPLING", count = 1 },
      { id = "COBBLESTONE", count = 8 },
      { id = "DIRT",        count = 16 }
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
    floating_time = 0,
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

  local block_below_id = world:get_block(self.int_x, self.int_y, self.int_z - world.layer_diff)

  if includes(NoCollision, block_below_id) and not includes(Climbable, block_below_id) then
    if self.floating_time >= 3 then
      -- fall if the player appears stuck in the air
      self:fall_towards(self.x, self.y)
      self.floating_time = 0
    else
      self.floating_time = self.floating_time + 1
    end
  end

  if Net.get_player_element(self.id) ~= "Fire" and includes(Liquids.Lava, world:get_block(self.int_x, self.int_y, self.int_z)) then
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

  local pos = Net.get_player_position(self.id)

  self:handle_tile_interaction(pos.x, pos.y, pos.z, button)
end

function Player:handle_tile_interaction(x, y, z, button)
  if not self.instance then
    return
  end

  local pos = self:get_interaction_position(x, y, z)

  x = math.floor(pos.x) + .5
  y = math.floor(pos.y) + .5

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

function Player:get_interaction_position(start_x, start_y, start_z)
  local direction = Net.get_player_direction(self.id)
  local pos = Direction.get_point_ahead({ x = start_x, y = start_y, z = start_z }, direction, .5)

  return pos
end

local direction_to_suffix = {
  [Direction.UP_RIGHT] = "_N",
  [Direction.RIGHT] = "_N",
  [Direction.DOWN_RIGHT] = "_E",
  [Direction.DOWN_LEFT] = "_S",
  [Direction.LEFT] = "_W",
  [Direction.UP_LEFT] = "_W",
}

function Player:get_block_direction_suffix(int_x, int_y)
  if self.int_y > int_y then
    return "_N"
  elseif self.int_x < int_x then
    return "_E"
  elseif self.int_y < int_y then
    return "_S"
  elseif self.int_x > int_x then
    return "_W"
  end

  -- try using the player's facing direction or fall back to north
  return direction_to_suffix[Net.get_player_direction(self.id)] or "_N"
end

local function place_block(player, x, y, z)
  local direction_suffix = player:get_block_direction_suffix(x, y)
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
    -- nothing to place, fall back to interaction
    self:try_interact(x, y, z)
    return
  end

  x = math.floor(x)
  y = math.floor(y)
  z = math.floor(z)

  local direction_suffix = self:get_block_direction_suffix(x, y)
  local block = Blocks[self.selected_item.id .. direction_suffix] or Blocks[self.selected_item.id]

  if not block then
    -- not placeable
    return
  end

  local world = self.instance.world

  -- test at the ground, feet, and head
  for z_offset = -world.layer_diff, world.layer_diff, world.layer_diff do
    local block_id = world:get_block(x, y, z + z_offset)

    if block_id == Blocks.AIR or includes(Liquids.Flowing, block_id) then
      return place_block(self, x, y, z + z_offset)
    end
  end
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
  local head_id = world:get_block(x, y, z + world.layer_diff)

  if head_id ~= Blocks.AIR and not includes(Liquids.All, head_id) then
    return break_block(self, x, y, z + world.layer_diff)
  end

  -- break the block at feet
  local feet_id = world:get_block(x, y, z)

  if feet_id ~= Blocks.AIR and not includes(Liquids.All, feet_id) then
    return break_block(self, x, y, z)
  end

  -- break the block below
  local floor_id = world:get_block(x, y, z - world.layer_diff)
  local can_jump_through_floor = floor_id == Blocks.AIR or includes(Liquids.All, floor_id)

  if not can_jump_through_floor then
    return break_block(self, x, y, z - world.layer_diff)
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
  local head_id = world:get_block(int_x, int_y, int_z + world.layer_diff)
  local ceiling_id = world:get_block(int_x, int_y, int_z + 2 * world.layer_diff)

  if (feet_id ~= Blocks.AIR and not includes(Liquids.NonFull, feet_id)) and includes(NoCollision, head_id) and includes(NoCollision, ceiling_id) then
    self:animate_jump_up(self.id, x, y, int_z + world.layer_diff)
  end

  -- try again on our current position instead of the target position
  -- makes it easier to climb ladders or swim
  if x ~= self.x and y ~= self.y then
    self:try_jump_up(self.x, self.y, z)
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
        { property = "Z", ease = "In",     value = z }
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

  local DEATH_ZONE = 0 -- todo: set to -8 when putting the player below 0 stops crashing the game
  local land_z = DEATH_ZONE
  local world = self.instance.world

  for test_z = self.int_z - 2 * world.layer_diff, 0, -world.layer_diff do
    local block_id = world:get_block(int_x, int_y, test_z)

    if not includes(NoCollision, block_id) or includes(Liquids.Full, block_id) then
      land_z = test_z + world.layer_diff
      break
    end
  end

  local time = self:animate_jump_down(self.id, x, y, land_z)

  Async.sleep(time).and_then(function()
    if land_z == DEATH_ZONE then
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

local interact_test_order = { 0, 1, -1 }

function Player:try_interact(x, y, z)
  x = math.floor(x)
  y = math.floor(y)

  local world = self.instance.world

  for _, i in ipairs(interact_test_order) do
    local test_z = z + i * world.layer_diff
    local block_id = world:get_block(x, y, test_z)

    if block_id == Blocks.CRAFTING_TABLE then
      self:open_menu(CraftingMenu:new(self, "Crafting Table", MenuColors.CRAFTING_TABLE_COLOR,
        CraftingRecipes.CraftingTable))
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
  self.menus[#self.menus + 1] = menu
  menu:open()
end

function Player:update_menu()
  local current_menu = self.menus[#self.menus]

  if not current_menu then
    return
  end

  current_menu:update()
end

function Player:close_menus()
  self.last_menu_count = 1
  Net.close_board(self.id)
  self.menus = {}
end

local function close_top_menu_internal(self)
  -- remove the last top menu
  self.menus[#self.menus] = nil

  self.last_menu_count = math.max(1, #self.menus)

  -- reopen the previous menu
  local top_menu = self.menus[#self.menus]

  if top_menu then
    top_menu:open()
  end
end

function Player:close_menu()
  close_top_menu_internal(self)
  self.last_menu_count = self.last_menu_count - 1

  if #self.menus == 0 then
    Net.close_board(self.id)
  end
end

function Player:handle_board_close()
  local last_menu_count = self.last_menu_count

  if last_menu_count < #self.menus then
    -- a menu has been opened on top as the menu count has gone up
    self.last_menu_count = math.max(1, #self.menus)
    return
  end

  close_top_menu_internal(self)
end

-- all messages to this player should be made through this class
function Player:message(message, texture_path, animation_path)
  return Async.message_player(self.id, message, texture_path, animation_path)
end

-- all messages to this player should be made through this class
function Player:message_with_mug(message)
  return self:message(message, self.avatar.texture_path, self.avatar.animation_path)
end

-- all questions to this player should be made through this class
function Player:question(question, texture_path, animation_path)
  return Async.question_player(self.id, question, texture_path, animation_path)
end

-- all questions to this player should be made through this class
function Player:question_with_mug(question)
  return self:question(question, self.avatar.texture_path, self.avatar.animation_path)
end

-- all quizzes to this player should be made through this class
function Player:quiz(a, b, c, texture_path, animation_path)
  return Async.quiz_player(self.id, a, b, c, texture_path, animation_path)
end

-- all prompts to this player should be made through this class
function Player:prompt(character_limit, default_text)
  return Async.prompt_player(self.id, character_limit, default_text)
end

return Player
