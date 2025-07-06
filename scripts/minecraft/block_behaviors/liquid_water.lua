local Block = require("scripts/minecraft/data/block")
local Liquids = require("scripts/minecraft/data/liquids")
local place_if_air = require("scripts/minecraft/block_behaviors/helpers").place_if_air
local includes = require("scripts/libs/includes")

-- local next_stage_map = {
--   [Blocks.WATER_FULL] = Blocks.WATER_7,
--   [Blocks.WATER_8] = Blocks.WATER_7,
--   [Blocks.WATER_7] = Blocks.WATER_6,
--   [Blocks.WATER_6] = Blocks.WATER_5,
--   [Blocks.WATER_5] = Blocks.WATER_4,
--   [Blocks.WATER_4] = Blocks.WATER_3,
--   [Blocks.WATER_3] = Blocks.WATER_2,
--   [Blocks.WATER_2] = Blocks.WATER_1,
--   [Blocks.WATER_1] = Blocks.AIR,
-- }

-- reduce lag by reducing water spread/levels
local next_stage_map = {
  [Block.WATER_FULL] = Block.WATER_7,
  [Block.WATER_8] = Block.WATER_6,
  [Block.WATER_7] = Block.WATER_6,
  [Block.WATER_6] = Block.WATER_5,
  [Block.WATER_5] = Block.WATER_3,
  [Block.WATER_4] = Block.WATER_3,
  [Block.WATER_3] = Block.WATER_2,
  [Block.WATER_2] = Block.AIR,
  [Block.WATER_1] = Block.AIR,
}

local higher_stages_map = {
  [Block.WATER_7] = { Block.WATER_8, Block.WATER_FULL },
  [Block.WATER_6] = { Block.WATER_7, Block.WATER_8, Block.WATER_FULL },
  [Block.WATER_5] = { Block.WATER_6, Block.WATER_7, Block.WATER_8, Block.WATER_FULL },
  [Block.WATER_4] = { Block.WATER_5, Block.WATER_6, Block.WATER_7, Block.WATER_8, Block.WATER_FULL },
  [Block.WATER_3] = { Block.WATER_4, Block.WATER_5, Block.WATER_6, Block.WATER_7, Block.WATER_8, Block.WATER_FULL },
  [Block.WATER_2] = { Block.WATER_3, Block.WATER_4, Block.WATER_5, Block.WATER_6, Block.WATER_7, Block.WATER_8, Block.WATER_FULL },
  [Block.WATER_1] = { Block.WATER_2, Block.WATER_3, Block.WATER_4, Block.WATER_5, Block.WATER_6, Block.WATER_7, Block.WATER_8, Block.WATER_FULL },
}

local function update(world, int_x, int_y, int_z, block_id)
  if block_id == Block.WATER_FULL then
    if not includes(Liquids.Water, world:get_block(int_x, int_y, int_z + world.layer_diff)) then
      -- no water above, convert to WATER_7
      world:set_block(int_x, int_y, int_z, next_stage_map[block_id])
    end
  elseif block_id ~= Block.WATER_8 then
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

  local block_below_id = world:get_block(int_x, int_y, int_z - world.layer_diff)

  if block_id ~= Block.WATER_1 and (block_id == Block.WATER_8 or (block_below_id ~= Block.AIR and not includes(Liquids.Water, block_below_id))) then
    -- spread sideways
    local next_stage = next_stage_map[block_id]
    place_if_air(world, int_x + 1, int_y, int_z, next_stage)
    place_if_air(world, int_x - 1, int_y, int_z, next_stage)
    place_if_air(world, int_x, int_y + 1, int_z, next_stage)
    place_if_air(world, int_x, int_y - 1, int_z, next_stage)
  end

  -- spread down
  place_if_air(world, int_x, int_y, int_z - world.layer_diff, Block.WATER_FULL)
end

return update
