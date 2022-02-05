local Occlusion = require("scripts/minecraft/occlusion")

local SyncedWorldInstance = {}

function SyncedWorldInstance:new(world, player, instance_id)
  local instance = {
    id = instance_id,
    world = world,
    player = player,
    player_mirrors = {}, -- { bot_id, player, avatar, x, y, z }
    occlusion = Occlusion:new(player)
  }

  Net.clone_area(world.area_id, instance_id)

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function SyncedWorldInstance:tick()
  self.occlusion:update_around(self.player.int_x, self.player.int_y, self.player.int_z)

  for _, mirror in ipairs(self.player_mirrors) do
    local player = mirror.player

    if mirror.x ~= player.x or mirror.y ~= player.y or mirror.z ~= player.z then
      mirror.x = player.x
      mirror.y = player.y
      mirror.z = player.z
      Net.move_bot(mirror.bot_id, player.x, player.y, player.z)
    end

    Net.set_bot_direction(mirror.bot_id, Net.get_player_direction(player.id))

    if player.avatar ~= mirror.avatar then
      mirror.avatar = player.avatar
      Net.set_bot_avatar(mirror.bot_id, mirror.avatar.texture_path, mirror.avatar.animation_path)
    end
  end
end

function SyncedWorldInstance:handle_player_move(player)
  self.occlusion:handle_player_move(player)
end

function SyncedWorldInstance:handle_player_emote(player, emote)
  for _, mirror in ipairs(self.player_mirrors) do
    if mirror.player == player then
      Net.set_bot_emote(mirror.bot_id, emote)
    end
  end
end

function SyncedWorldInstance:add_player_mirror(player, warp_in)
  local bot_id = Net.create_bot({
    name = Net.get_player_name(player.id),
    area_id = self.id,
    warp_in = warp_in,
    texture_path = player.avatar.texture_path,
    animation_path = player.avatar.animation_path,
    x = player.x,
    y = player.y,
    z = player.z,
    direction = Net.get_player_direction(player.id)
  })

  self.player_mirrors[#self.player_mirrors+1] = {
    bot_id = bot_id,
    player = player,
    x = player.x,
    y = player.y,
    z = player.z,
  }
end

function SyncedWorldInstance:remove_player_mirror(player)
  for i, mirror in ipairs(self.player_mirrors) do
    if mirror.player == player then
      Net.remove_bot(mirror.bot_id)
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
