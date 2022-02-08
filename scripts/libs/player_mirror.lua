local PlayerMirror = {}

local PIXELS_PER_TILE = 14 -- SPECIFIC TO THIS SERVER, USE TILE HEIGHT TO RESOLVE
local TICKS_PER_SECOND = 20

local WALK_SPEED = 70 / PIXELS_PER_TILE / TICKS_PER_SECOND
local RUN_SPEED = 140 / PIXELS_PER_TILE / TICKS_PER_SECOND
local REDUCED_WALK_SPEED = 3 / PIXELS_PER_TILE
local RUN_DIST = RUN_SPEED * 2
local WALK_DIST = WALK_SPEED * 3
local CATCH_UP_DIST = REDUCED_WALK_SPEED
local TELEPORT_DIST = 3

local function world_to_screen(x, y)
  return x - y, (x + y) * .5
end

local function screen_to_world(x, y)
  return (2 * y + x) * .5, (2 * y - x) * .5
end

function PlayerMirror:new(area_id, player_id, x, y, z, warp_in)
  local avatar = Net.get_player_avatar(player_id)

  local bot_id = Net.create_bot({
    name = Net.get_player_name(player_id),
    area_id = area_id,
    warp_in = warp_in,
    texture_path = avatar.texture_path,
    animation_path = avatar.animation_path,
    x = x,
    y = y,
    z = z,
    direction = Net.get_player_direction(player_id)
  })

  local screen_x, screen_y = world_to_screen(x, y)

  local player_mirror = {
    bot_id = bot_id,
    player_id = player_id,
    screen_x = screen_x,
    screen_y = screen_y,
    screen_z = z,
    target_screen_x = screen_x,
    target_screen_y = screen_y,
    target_z = z,
  }

  setmetatable(player_mirror, self)
  self.__index = self

  return player_mirror
end

function PlayerMirror:tick()
  local screen_x_diff = self.target_screen_x - self.screen_x
  local screen_y_diff = self.target_screen_y - self.screen_y

  local chebyshev_dist = math.max(math.abs(screen_x_diff), math.abs(screen_y_diff))

  if chebyshev_dist > TELEPORT_DIST then
    self.screen_x = self.target_screen_x
    self.screen_y = self.target_screen_y
    if chebyshev_dist > TELEPORT_DIST then
      self.screen_z = self.target_z
    end
  elseif chebyshev_dist >= CATCH_UP_DIST then
    local speed

    if chebyshev_dist >= RUN_DIST then
      speed = RUN_SPEED
    elseif chebyshev_dist >= WALK_DIST then
      speed = WALK_SPEED
    else
      speed = REDUCED_WALK_SPEED
    end

    self.screen_x = self.screen_x + screen_x_diff / chebyshev_dist * speed
    self.screen_y = self.screen_y + screen_y_diff / chebyshev_dist * speed
  end

  self.screen_z = self.screen_z + (self.target_z - self.screen_z) * .8

  local world_x, world_y = screen_to_world(self.screen_x, self.screen_y)
  Net.move_bot(self.bot_id, world_x, world_y, self.screen_z)
  Net.set_bot_direction(self.bot_id, Net.get_player_direction(self.player_id))
end

function PlayerMirror:handle_player_move(x, y, z)
  local screen_x, screen_y = world_to_screen(x, y)

  self.target_screen_x = screen_x
  self.target_screen_y = screen_y
  self.target_z = z
end

function PlayerMirror:handle_player_avatar_change(details)
  self.texture_path = details.texture_path
  self.animation_path = details.animation_path
  Net.set_bot_avatar(self.bot_id, self.texture_path, self.animation_path)
end

function PlayerMirror:handle_player_emote(emote)
  Net.set_bot_emote(self.bot_id, emote)
end

function PlayerMirror:destroy()
  Net.remove_bot(self.bot_id)
end

return PlayerMirror
