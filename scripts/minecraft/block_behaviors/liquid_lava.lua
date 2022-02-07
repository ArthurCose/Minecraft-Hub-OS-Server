local Blocks = require("scripts/minecraft/data/blocks")
local Liquids = require("scripts/minecraft/data/liquids")
local place_if_air = require("scripts/minecraft/block_behaviors/helpers").place_if_air
local includes = require("scripts/libs/includes")

local next_stage_map = {
  [Blocks.LAVA_FULL] = Blocks.LAVA_3,
  [Blocks.LAVA_4] = Blocks.LAVA_3,
  [Blocks.LAVA_3] = Blocks.LAVA_2,
  [Blocks.LAVA_2] = Blocks.LAVA_1,
  [Blocks.LAVA_1] = Blocks.AIR,
}

local higher_stages_map = {
  [Blocks.LAVA_3] = { Blocks.LAVA_4, Blocks.LAVA_FULL },
  [Blocks.LAVA_2] = { Blocks.LAVA_3, Blocks.LAVA_4, Blocks.LAVA_FULL },
  [Blocks.LAVA_1] = { Blocks.LAVA_2, Blocks.LAVA_3, Blocks.LAVA_4, Blocks.LAVA_FULL },
}

local function has_water_neighbor(world, int_x, int_y, int_z)
  return (
    includes(Liquids.Water, world:get_block(int_x + 1, int_y, int_z)) or
    includes(Liquids.Water, world:get_block(int_x - 1, int_y, int_z)) or
    includes(Liquids.Water, world:get_block(int_x, int_y + 1, int_z)) or
    includes(Liquids.Water, world:get_block(int_x, int_y - 1, int_z)) or
    includes(Liquids.Water, world:get_block(int_x, int_y, int_z + world.layer_diff)) or
    includes(Liquids.Water, world:get_block(int_x, int_y, int_z - world.layer_diff))
  )
end

local function update(world, int_x, int_y, int_z, block_id)
  local block_below_id = world:get_block(int_x, int_y, int_z - world.layer_diff)

  if includes(Liquids.Water, block_below_id) then
    -- convert water below to stone
    world:set_block(int_x, int_y, int_z - world.layer_diff, Blocks.STONE)
    return
  end

  if has_water_neighbor(world, int_x, int_y, int_z) then
    if block_id == Blocks.LAVA_4 then
      world:set_block(int_x, int_y, int_z, Blocks.OBSIDIAN)
    else
      world:set_block(int_x, int_y, int_z, Blocks.COBBLESTONE)
    end
    return
  end

  if math.random(2) == 1 then
    -- only update half the time to move slower than water
    return
  end

  if block_id == Blocks.LAVA_FULL then
    if not includes(Liquids.Lava, world:get_block(int_x, int_y, int_z + world.layer_diff)) then
      -- no lava above, convert to LAVA_3
      world:set_block(int_x, int_y, int_z, next_stage_map[block_id])
    end
  elseif block_id ~= Blocks.LAVA_4 then
    -- see if the neighbor is at a higher stage, if we don't we need to evaporate
    local higher_stages = higher_stages_map[block_id]
    local has_higher_stage_neighbor = (
      includes(higher_stages, world:get_block(int_x + 1, int_y, int_z)) or
      includes(higher_stages, world:get_block(int_x - 1, int_y, int_z)) or
      includes(higher_stages, world:get_block(int_x, int_y + 1, int_z)) or
      includes(higher_stages, world:get_block(int_x, int_y - 1, int_z))
    )

    if not has_higher_stage_neighbor then
      local next_stage = next_stage_map[block_id]
      world:set_block(int_x, int_y, int_z, next_stage)
    end
  end

  if block_id ~= Blocks.LAVA_1 and (block_id == Blocks.LAVA_4 or (block_below_id ~= Blocks.AIR and not includes(Liquids.Lava, block_below_id))) then
    -- spread sideways
    local next_stage = next_stage_map[block_id]
    place_if_air(world, int_x + 1, int_y, int_z, next_stage)
    place_if_air(world, int_x - 1, int_y, int_z, next_stage)
    place_if_air(world, int_x, int_y + 1, int_z, next_stage)
    place_if_air(world, int_x, int_y - 1, int_z, next_stage)
  end

  -- spread down
  place_if_air(world, int_x, int_y, int_z - world.layer_diff, Blocks.LAVA_FULL)
end

return update
