local Blocks = require("scripts/minecraft/data/blocks")
local includes = require("scripts/lib/includes")

local dirt_plantable_blocks = {
  Blocks.DIRT,
  Blocks.GRASS,
  Blocks.PODZOL,
}

local function place_if_air(world, int_x, int_y, int_z, block_id)
  if world:get_block(int_x, int_y, int_z) == Blocks.AIR then
    world:set_block(int_x, int_y, int_z, block_id)
  end
end

function sapling(world, int_x, int_y, int_z)
  local block_below_id = world:get_block(int_x, int_y, int_z - 2)

  if not includes(dirt_plantable_blocks, block_below_id) then
    -- kill it
    world:set_block(int_x, int_y, int_z, Blocks.AIR)
    return
  end

  if math.random(32) > 1 then
    -- failed to grow
    return
  end

  -- grow
  local block_id = world:get_block(int_x, int_y, int_z)

  if block_id == Blocks.OAK_SAPLING then
    -- grow an oak tree
    local height = math.random(3) + 4

    world:set_block(int_x, int_y, int_z, Blocks.OAK_LOG)

    for layer = 1, height - 1, 1 do
      local place_z = int_z + layer * world.layer_diff

      if layer == height - 1 then
        -- plus shape of leaves
        place_if_air(world, int_x, int_y, place_z, Blocks.OAK_LEAVES)
        place_if_air(world, int_x - 1, int_y, place_z, Blocks.OAK_LEAVES)
        place_if_air(world, int_x + 1, int_y, place_z, Blocks.OAK_LEAVES)
        place_if_air(world, int_x, int_y - 1, place_z, Blocks.OAK_LEAVES)
        place_if_air(world, int_x, int_y + 1, place_z, Blocks.OAK_LEAVES)
      elseif layer == height - 2 then
        -- plus shape of leaves, log in center, with a random jumpable leaves
        place_if_air(world, int_x, int_y, place_z, Blocks.OAK_LOG)
        place_if_air(world, int_x - 1, int_y, place_z, Blocks.OAK_LEAVES)
        place_if_air(world, int_x + 1, int_y, place_z, Blocks.OAK_LEAVES)
        place_if_air(world, int_x, int_y - 1, place_z, Blocks.OAK_LEAVES)
        place_if_air(world, int_x, int_y + 1, place_z, Blocks.OAK_LEAVES)

        -- random corner leaves
        if math.random(4) == 1 then place_if_air(world, int_x - 1, int_y - 1, place_z, Blocks.OAK_LEAVES) end
        if math.random(4) == 1 then place_if_air(world, int_x - 1, int_y + 1, place_z, Blocks.OAK_LEAVES) end
        if math.random(4) == 1 then place_if_air(world, int_x + 1, int_y - 1, place_z, Blocks.OAK_LEAVES) end
        if math.random(4) == 1 then place_if_air(world, int_x + 1, int_y + 1, place_z, Blocks.OAK_LEAVES) end
      elseif layer >= height - 4 then
        place_if_air(world, int_x, int_y, place_z, Blocks.OAK_LOG)

        -- widest area
        for i = -1, 1 do
          for j = -2, 2 do
            place_if_air(world, int_x + i, int_y + j, place_z, Blocks.OAK_LEAVES)
          end
          place_if_air(world, int_x - 2, int_y + i, place_z, Blocks.OAK_LEAVES)
          place_if_air(world, int_x + 2, int_y + i, place_z, Blocks.OAK_LEAVES)
        end

        -- random corner leaves
        if math.random(4) == 1 then place_if_air(world, int_x - 2, int_y - 2, place_z, Blocks.OAK_LEAVES) end
        if math.random(4) == 1 then place_if_air(world, int_x - 2, int_y + 2, place_z, Blocks.OAK_LEAVES) end
        if math.random(4) == 1 then place_if_air(world, int_x + 2, int_y - 2, place_z, Blocks.OAK_LEAVES) end
        if math.random(4) == 1 then place_if_air(world, int_x + 2, int_y + 2, place_z, Blocks.OAK_LEAVES) end
      else
        -- just place the trunk
        place_if_air(world, int_x, int_y, place_z, Blocks.OAK_LOG)
      end
    end
  end
end

function grass(world, int_x, int_y, int_z)
  if math.random(8) > 1 then
    return
  end

  local spread_x = int_x + math.random(3) - 2
  local spread_y = int_y + math.random(3) - 2
  local spread_z = int_z + (math.random(3) - 2) * world.layer_diff

  if world:get_block(spread_x, spread_y, spread_z) == Blocks.DIRT and world:get_block(spread_x, spread_y, spread_z + world.layer_diff) == Blocks.AIR then
    world:set_block(spread_x, spread_y, spread_z, Blocks.GRASS)
  end

  -- todo: death, need to handle transparent blocks
end


local BlockTicks = {
  [Blocks.OAK_SAPLING] = sapling,
  [Blocks.GRASS] = grass
}

return BlockTicks