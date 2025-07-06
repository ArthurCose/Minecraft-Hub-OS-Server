local Occlusion = require("scripts/minecraft/occlusion")
local SelectionPreview = require("scripts/minecraft/selection_preview")
local PlayerMirror = require("scripts/libs/player_mirror")

---@class SyncedWorldInstance
---@field id string,
---@field world World
---@field player Player
---@field player_mirrors PlayerMirror[]
---@field occlusion Occlusion
---@field selection_preview SelectionPreview
local SyncedWorldInstance = {}

---@param world World
---@param player Player
---@param instance_id string
function SyncedWorldInstance:new(world, player, instance_id)
  ---@type SyncedWorldInstance
  local instance = {
    id = instance_id,
    world = world,
    player = player,
    player_mirrors = {},
    occlusion = Occlusion:new(player),
    selection_preview = SelectionPreview:new(),
  }

  Net.clone_area(world.area_id, instance_id)

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function SyncedWorldInstance:tick()
  self.selection_preview:update(self.world, self.player)
  self.occlusion:update_around(self.player.int_x, self.player.int_y, self.player.int_z)

  for _, mirror in ipairs(self.player_mirrors) do
    mirror:handle_player_move(mirror.player.x, mirror.player.y, mirror.player.z)
    mirror:tick()

    local latest_avatar = mirror.player.avatar

    if latest_avatar ~= mirror.avatar then
      mirror:handle_player_avatar_change(latest_avatar)
      mirror.avatar = latest_avatar
    end
  end
end

---@param player Player
function SyncedWorldInstance:handle_player_move(player)
  self.occlusion:handle_player_move(player)
end

---@param player Player
---@param emote string
function SyncedWorldInstance:handle_player_emote(player, emote)
  for _, mirror in ipairs(self.player_mirrors) do
    if mirror.player == player then
      mirror:handle_player_emote(emote)
    end
  end
end

---@param player Player
---@param warp_in boolean
function SyncedWorldInstance:add_player_mirror(player, warp_in)
  local mirror = PlayerMirror:new(self.id, player, warp_in)

  self.player_mirrors[#self.player_mirrors + 1] = mirror
end

---@param player Player
function SyncedWorldInstance:remove_player_mirror(player)
  for i, mirror in ipairs(self.player_mirrors) do
    if mirror.player == player then
      mirror:destroy()
      table.remove(self.player_mirrors, i)
      break
    end
  end
end

function SyncedWorldInstance:destroy()
  self.occlusion:clear_all_layers()
  Net.remove_area(self.id)
end

return SyncedWorldInstance
