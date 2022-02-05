local Blocks = require("scripts/minecraft/blocks")
local SyncedWorldInstance = require("scripts/minecraft/synced_world_instance")
local includes = require("scripts/lib/includes")

local World = {
  player_layer_offset = 1,
  layer_diff = 2,
}

function World:new(area_id)
  local world = {
    area_id = "default",
    first_walkable_gid = 0,
    first_collidable_gid = 0,
    spawn_x = 0,
    spawn_y = 0,
    spawn_z = 0,
    width = 0,
    height = 0,
    layers = 0,
    blocks = {}, -- int[][][]
    tile_entities = {}, -- { x, y, z, data, deleted? }[]
    players = {},
  }

  setmetatable(world, self)
  self.__index = self

  world:use_area(area_id)

  return world
end

local function resolve_block_id(world, x, y, z)
  local tile_data = Net.get_tile(world.area_id, x, y, z)

  if not tile_data or tile_data.gid < world.first_walkable_gid then
    return Blocks.AIR
  end

  return tile_data.gid - world.first_walkable_gid
end

local function set_tile(world, x, y, z, gid)
  Net.set_tile(world.area_id, x, y, z, gid)

  for _, player in pairs(world.players) do
    Net.set_tile(player.instance.id, x, y, z, gid)
  end
end

local function update_tile(world, x, y, z)
  local render_block_z = z + World.player_layer_offset * World.layer_diff
  local render_block_id = world:get_block(x, y, render_block_z)
  local feet_block_z = render_block_z - World.player_layer_offset * World.layer_diff
  local feet_block_id = world:get_block(x, y, feet_block_z)

  if feet_block_id ~= Blocks.AIR then
    -- block in the way
    set_tile(world, x, y, z, world.first_collidable_gid + render_block_id)
    return
  end

  local head_block_z = feet_block_z + World.layer_diff
  local head_block_id = world:get_block(x, y, head_block_z)

  if head_block_id ~= Blocks.AIR then
    -- block in the way
    set_tile(world, x, y, z, world.first_collidable_gid + render_block_id)
    return
  end

  local ground_block_id = world:get_block(x, y, feet_block_z - World.layer_diff)

  if ground_block_id == Blocks.AIR and render_block_id == Blocks.AIR then
    -- no ground
    -- just set it to blank if there's no collision and it should appear as air
    set_tile(world, x, y, z, 0)
  elseif ground_block_id == Blocks.AIR then
    -- no floor to walk on
    set_tile(world, x, y, z, world.first_collidable_gid + render_block_id)
  else
    -- we can walk through air if there's ground
    set_tile(world, x, y, z, world.first_walkable_gid + render_block_id)
  end
end

function World:use_area(area_id)
  self.area_id = area_id
  self.first_walkable_gid = Net.get_tileset(area_id, "/server/assets/tiles/blocks.tsx").first_gid
  self.first_collidable_gid = Net.get_tileset(area_id, "/server/assets/tiles/collidable_blocks.tsx").first_gid

  self.width = Net.get_width(area_id)
  self.height = Net.get_height(area_id)
  self.layers = math.ceil(Net.get_layer_count(area_id) / World.layer_diff) - 1 - World.player_layer_offset

  -- load map into self.blocks
  for z = 0, self.layers - 1 do
    local layer = {}
    self.blocks[z + 1] = layer

    for y = 0, self.height - 1 do
      local row = {}
      layer[y + 1] = row

      for x = 0, self.width - 1 do
        local block_id = resolve_block_id(self, x, y, z * World.layer_diff)
        row[x + 1] = block_id

        if block_id == Blocks.BEDROCK then
          -- resolve spawn_z through set_spawn_position later
          self.spawn_x = x
          self.spawn_y = y
        end
      end
    end
  end

  -- adjust collisions
  for z = 0, self.layers + 1 do -- intentional +1, will update collisions for the top most layer
    for y = 0, self.height - 1 do
      for x = 0, self.width - 1 do
        -- should handle collisions for us
        update_tile(self, x, y, z * World.layer_diff)
      end
    end
  end

  -- resolve spawn_z
  self:set_spawn_position(self.spawn_x, self.spawn_y)
end

function World:get_block(x, y, z)
  z = math.floor(z / World.layer_diff) - World.player_layer_offset
  local layer = self.blocks[z + 1]
  if layer == nil then return Blocks.AIR end
  local row = layer[y + 1]
  if row == nil then return Blocks.AIR end
  return row[x + 1] or Blocks.AIR
end

function World:set_block(x, y, z, block_id)
  local layerIndex = math.floor(z / World.layer_diff) + 1 - World.player_layer_offset
  local layer = self.blocks[layerIndex]
  if layer == nil then return false end
  local row = layer[y + 1]
  if row == nil then return false end
  local original_block_id = row[x + 1]
  if original_block_id == nil then return false end

  for _, player in pairs(self.players) do
    if player.int_x == x and player.int_y == y and (player.int_z == z or player.int_z + World.layer_diff == z) then
      -- player standing where we want to place the block
      return false
    end
  end

  if includes(Blocks.TileEntities, original_block_id) then
    local tile_entity
    local index

    for i, e in ipairs(self.tile_entities) do
      if e.x == x and e.y == y and e.z == z then
        tile_entity = e
        index = i
        break
      end
    end

    if tile_entity then
      if tile_entity.data.items and #tile_entity.data.items > 0 then
        -- don't allow this to break unless all of the items are taken out
        return false
      end

      tile_entity.deleted = true
      table.remove(self.tile_entities, index)
    end
  end

  row[x + 1] = block_id

  update_tile(self, x, y, z - World.player_layer_offset * World.layer_diff)
  update_tile(self, x, y, z)
  update_tile(self, x, y, z + World.player_layer_offset * World.layer_diff)

  if block_id == Blocks.AIR and not includes(Blocks.TileEntities, block_id) then
  end

  if self.spawn_x == x and self.spawn_y == y then
    -- recalculate spawn z
    self:set_spawn_position(x, y)
  end

  return true
end

function World:set_spawn_position(x, y)
  self.spawn_x = x
  self.spawn_y = y

  for z = World.player_layer_offset * World.layer_diff, self.layers - 1, World.layer_diff do
    local id = self:get_block(x, y, z)

    if id == Blocks.AIR then
      self.spawn_z = z
      break
    end
  end

  Net.set_spawn_position(self.area_id, x + .5, y + .5, self.spawn_z)
end

-- finds the tile entity or makes a new one
function World:request_tile_entity(x, y, z)
  local block_id = self:get_block(x, y, z)

  if not includes(Blocks.TileEntities, block_id) then
    return
  end

  -- search for the tile entity
  for _, e in ipairs(self.tile_entities) do
    if e.x == x and e.y == y and e.z == z then
      return e
    end
  end

  -- none found, make a new one
  local tile_entity = {
    x = x,
    y = y,
    z = z,
    data = {}
  }

  self.tile_entities[#self.tile_entities+1] = tile_entity
  return tile_entity
end

function World:connect_player(player)
  player.instance = SyncedWorldInstance:new(self, player, "minecraft-" .. player.id)

  for _, other_player in pairs(self.players) do
    -- add other player's to this player's instance
    player.instance:add_player_mirror(other_player, false)
  end

  Net.transfer_player(player.id, player.instance.id, true)
  self.players[player.id] = player
end

function World:handle_player_join(player)
  -- add the player to other instances
  for _, other_player in pairs(self.players) do
    if player ~= other_player then
      other_player.instance:add_player_mirror(player, true)
    end
  end
end

function World:disconnect_player(player)
  player.instance:destroy()
  player.instance = nil
  self.players[player.id] = nil

  -- remove the player from other instances
  for _, other_player in pairs(self.players) do
    other_player.instance:remove_player_mirror(player)
  end
end

function World:tick()
  for _, player in pairs(self.players) do
    player.instance:tick()
  end
end

return World
