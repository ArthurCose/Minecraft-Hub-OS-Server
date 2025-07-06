local Block = require("scripts/minecraft/data/block")
local Liquids = require("scripts/minecraft/data/liquids")
local PlayerActions = require("scripts/minecraft/player_actions")

local TEXTURE_PATH = "/server/assets/bots/selection.png"
local ANIMATION_PATH = "/server/assets/bots/selection.animation"

local InteractionType = {
  BREAK = 0,
  PLACE = 1
}

---@class SelectionPreview
---@field bot_id Net.ActorId?
---@field int_x number
---@field int_y number
---@field int_z number
---@field animation string
local SelectionPreview = {}

function SelectionPreview:new()
  ---@type SelectionPreview
  local selection_preview = {
    bot_id = nil,
    int_x = 0,
    int_y = 0,
    int_z = 0,
    animation = ""
  }

  setmetatable(selection_preview, self)
  self.__index = self

  return selection_preview
end

---@param world World
---@param player Player
local function resolve_interaction_type(player, world, int_x, int_y, int_z)
  if player.action == PlayerActions.ITEM and player.selected_item then
    local suffix = player:get_block_direction_suffix(int_x, int_y)

    if world:in_bounds(int_x, int_y, int_z) and Block[player.selected_item.id] or Block[player.selected_item.id .. suffix] then
      return InteractionType.PLACE
    end
  elseif player.action == PlayerActions.PUNCH then
    return InteractionType.BREAK
  end
  return nil
end

---@param world World
---@param player Player
function SelectionPreview:update(world, player)
  local interaction_pos = player:get_interaction_position(player.x, player.y, player.z)
  local int_x = math.floor(interaction_pos.x)
  local int_y = math.floor(interaction_pos.y)
  local int_z = math.floor(interaction_pos.z)

  local interaction_type = resolve_interaction_type(player, world, int_x, int_y, int_z)
  local new_x, new_y, new_z, new_animation

  if interaction_type == InteractionType.PLACE then
    for z_offset = -world.layer_diff, world.layer_diff, world.layer_diff do
      local block_id = world:get_block(int_x, int_y, int_z + z_offset)

      if block_id == Block.AIR or includes(Liquids.Flowing, block_id) then
        new_x = int_x
        new_y = int_y
        new_z = int_z + z_offset
        new_animation = "PLACE_" .. z_offset
        break
      end
    end
  elseif interaction_type == InteractionType.BREAK then
    for z_offset = world.layer_diff, -world.layer_diff, -world.layer_diff do
      local block_id = world:get_block(int_x, int_y, int_z + z_offset)

      if block_id ~= Block.AIR and not includes(Liquids.All, block_id) then
        local suffix

        if z_offset > -world.layer_diff then
          suffix = player:get_block_direction_suffix(int_x, int_y)
        else
          suffix = ""
        end

        new_x = int_x
        new_y = int_y
        new_z = int_z + z_offset

        new_animation = "BREAK_" .. z_offset .. suffix
        break
      end
    end
  end

  if not new_animation then
    if self.bot_id then
      self.animation = nil
      -- no need for a selection bot
      Net.remove_bot(self.bot_id)
    end
    return
  end

  if self.int_x ~= new_x or self.int_y ~= new_y or self.int_z ~= new_z or self.animation ~= new_animation then
    self.int_x = new_x
    self.int_y = new_y
    self.int_z = new_z
    self.animation = new_animation

    if self.bot_id then
      Net.remove_bot(self.bot_id)
    end

    local z_offset = new_z - player.int_z

    self.bot_id = Net.create_bot({
      area_id = player.instance.id,
      texture_path = TEXTURE_PATH,
      animation_path = ANIMATION_PATH,
      animation = new_animation,
      x = new_x + .5 + .02 * z_offset + (3 / 14),
      y = new_y + .5 + .02 * z_offset + (3 / 14),
      z = player.int_z,
      warp_in = false,
    })
  end
end

return SelectionPreview
