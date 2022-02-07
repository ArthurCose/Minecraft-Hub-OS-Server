local texture_path = "/server/assets/tiles/blocks.png"
local BotAnimation = require("scripts/minecraft/occlusion_bot_animation")
local Blocks = require("scripts/minecraft/data/blocks")

local Occlusion = {}

-- chebyshev distance
local FALLING_SPAWN_RANGE = 1
local SPAWN_RANGE = 5
local DESPAWN_RANGE = 5

function Occlusion:new(player)
  local occlusion = {
    player = player,
    last_int_x = 0,
    last_int_y = 0,
    last_int_z = 0,
    bot_layers = {}, -- [int_z] = pillar { int_x, int_y, int_z, bots = { id, block_id, z_offset }[] }
  }

  setmetatable(occlusion, self)
  self.__index = self

  return occlusion
end

function Occlusion:clear_layer(int_z)
  local bot_layer = self.bot_layers[int_z]

  if not bot_layer then
    return
  end

  for _, pillar in ipairs(bot_layer) do
    for _, bot in ipairs(pillar.bots) do
      if bot.id then
        Net.remove_bot(bot.id)
      end
    end
  end

  self.bot_layers[int_z] = nil
end

function Occlusion:clear_all_layers()
  -- delete all layers
  for z, _ in pairs(self.bot_layers) do
    self:clear_layer(z)
  end
end

local function create_bot(block_id, area_id, z_offset, int_x, int_y, int_z)
  return Net.create_bot({
    texture_path = texture_path,
    animation_path = BotAnimation.path,
    animation = BotAnimation.get_state(block_id, z_offset),
    area_id = area_id,
    warp_in = false,
    x = int_x + .5 + .02 * z_offset,
    y = int_y + .5 + .02 * z_offset,
    z = int_z
  })
end

local function create_pillar(self, int_x, int_y, int_z)
  local pillar = {
    int_x = int_x,
    int_y = int_y,
    int_z = int_z,
    bots = {}
  }

  local world = self.player.instance.world
  local area_id = self.player.instance.id

  for z_offset = 0, world.layer_diff, world.layer_diff do
    local block_id = world:get_block(int_x, int_y, int_z + z_offset)

    local bot_id = nil

    if block_id ~= Blocks.AIR then
      bot_id = create_bot(block_id, area_id, z_offset, int_x, int_y, int_z)
    end

    pillar.bots[#pillar.bots+1] = {
      id = bot_id,
      block_id = block_id,
      z_offset = z_offset,
    }
  end

  return pillar
end

local function update_pillar(self, pillar)
  local world = self.player.instance.world
  local area_id = self.player.instance.id

  for _, bot in ipairs(pillar.bots) do
    local block_id = world:get_block(pillar.int_x, pillar.int_y, pillar.int_z + bot.z_offset)

    if bot.block_id ~= block_id then
      bot.block_id = block_id

      if block_id == Blocks.AIR then
        Net.remove_bot(bot.id)
        bot.id = nil
      elseif not bot.id then
        bot.id = create_bot(block_id, area_id, bot.z_offset, pillar.int_x, pillar.int_y, pillar.int_z)
      else
        local state = BotAnimation.get_state(block_id, bot.z_offset)
        Net.animate_bot(bot.id, state, true)
      end
    end
  end
end

function Occlusion:update_around(int_x, int_y, int_z)
  local bot_layer = self.bot_layers[int_z]

  if not bot_layer then
    bot_layer = {}
    self.bot_layers[int_z] = bot_layer
  end

  local spawn_range = SPAWN_RANGE

  if self.player.changing_z then
    spawn_range = FALLING_SPAWN_RANGE
  end

  for x = int_x - spawn_range, int_x + spawn_range, 1 do
    for y = int_y - spawn_range, int_y + spawn_range, 1 do
      local pillar

      for _, _pillar in ipairs(bot_layer) do
        if _pillar.int_x == x and _pillar.int_y == y then
          pillar = _pillar
          update_pillar(self, pillar)
          break
        end
      end

      if not pillar then
        bot_layer[#bot_layer + 1] = create_pillar(self, x, y, int_z)
      end
    end
  end
end


function Occlusion:despawn_out_of_range(int_z)
  local bot_layer = self.bot_layers[int_z]

  if not bot_layer then
    return
  end

  local pending_removal = {}

  for i, pillar in ipairs(bot_layer) do
    local chebyshev_distance = math.max(math.abs(pillar.int_x - self.player.int_x), math.abs(pillar.int_y - self.player.int_y))

    if chebyshev_distance > DESPAWN_RANGE then
      pending_removal[#pending_removal+1] = i
    end
  end

  for i = #pending_removal, 1, -1 do
    local pillar = table.remove(bot_layer, pending_removal[i])

    for _, bot in ipairs(pillar.bots) do
      if bot.id then
        Net.remove_bot(bot.id)
      end
    end
  end
end

function Occlusion:handle_player_move(player)
  local same_position = (
    self.last_int_x == player.int_x and
    self.last_int_y == player.int_y and
    self.last_int_z == player.int_z
  )

  if same_position then
    return
  end

  if self.last_int_z ~= player.int_z then
    -- changed layer, delete all bots
    self:clear_all_layers()
  end

  self.last_int_x = player.int_x
  self.last_int_y = player.int_y
  self.last_int_z = player.int_z

  self:update_around(player.int_x, player.int_y, player.int_z)

  self:despawn_out_of_range(player.int_z)
end

return Occlusion
