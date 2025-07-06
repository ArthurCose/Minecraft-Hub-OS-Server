local Block = require("scripts/minecraft/data/block")
local Tags = require("scripts/minecraft/data/tags")
local Helpers = require("scripts/minecraft/block_behaviors/helpers")
local includes = require("scripts/libs/includes")

local place_if_air = Helpers.place_if_air

local dirt_block_ids = Helpers.get_block_ids(Tags["#dirt"])

local function update(world, int_x, int_y, int_z)
  local block_below_id = world:get_block(int_x, int_y, int_z - world.layer_diff)

  if not includes(dirt_block_ids, block_below_id) then
    -- kill it
    world:set_block(int_x, int_y, int_z, Block.AIR)
    return
  end

  if math.random(32) > 1 then
    -- failed to grow
    return
  end

  -- grow
  local block_id = world:get_block(int_x, int_y, int_z)

  if block_id == Block.OAK_SAPLING then
    -- grow an oak tree
    local height = math.random(3) + 4

    world:set_block(int_x, int_y, int_z, Block.OAK_LOG)

    for layer = 1, height - 1, 1 do
      local place_z = int_z + layer * world.layer_diff

      if layer == height - 1 then
        -- plus shape of leaves
        place_if_air(world, int_x, int_y, place_z, Block.OAK_LEAVES)
        place_if_air(world, int_x - 1, int_y, place_z, Block.OAK_LEAVES)
        place_if_air(world, int_x + 1, int_y, place_z, Block.OAK_LEAVES)
        place_if_air(world, int_x, int_y - 1, place_z, Block.OAK_LEAVES)
        place_if_air(world, int_x, int_y + 1, place_z, Block.OAK_LEAVES)
      elseif layer == height - 2 then
        -- plus shape of leaves, log in center, with a random jumpable leaves
        place_if_air(world, int_x, int_y, place_z, Block.OAK_LOG)
        place_if_air(world, int_x - 1, int_y, place_z, Block.OAK_LEAVES)
        place_if_air(world, int_x + 1, int_y, place_z, Block.OAK_LEAVES)
        place_if_air(world, int_x, int_y - 1, place_z, Block.OAK_LEAVES)
        place_if_air(world, int_x, int_y + 1, place_z, Block.OAK_LEAVES)

        -- random corner leaves
        if math.random(4) == 1 then place_if_air(world, int_x - 1, int_y - 1, place_z, Block.OAK_LEAVES) end
        if math.random(4) == 1 then place_if_air(world, int_x - 1, int_y + 1, place_z, Block.OAK_LEAVES) end
        if math.random(4) == 1 then place_if_air(world, int_x + 1, int_y - 1, place_z, Block.OAK_LEAVES) end
        if math.random(4) == 1 then place_if_air(world, int_x + 1, int_y + 1, place_z, Block.OAK_LEAVES) end
      elseif layer >= height - 4 then
        place_if_air(world, int_x, int_y, place_z, Block.OAK_LOG)

        -- widest area
        for i = -1, 1 do
          for j = -2, 2 do
            place_if_air(world, int_x + i, int_y + j, place_z, Block.OAK_LEAVES)
          end
          place_if_air(world, int_x - 2, int_y + i, place_z, Block.OAK_LEAVES)
          place_if_air(world, int_x + 2, int_y + i, place_z, Block.OAK_LEAVES)
        end

        -- random corner leaves
        if math.random(4) == 1 then place_if_air(world, int_x - 2, int_y - 2, place_z, Block.OAK_LEAVES) end
        if math.random(4) == 1 then place_if_air(world, int_x - 2, int_y + 2, place_z, Block.OAK_LEAVES) end
        if math.random(4) == 1 then place_if_air(world, int_x + 2, int_y - 2, place_z, Block.OAK_LEAVES) end
        if math.random(4) == 1 then place_if_air(world, int_x + 2, int_y + 2, place_z, Block.OAK_LEAVES) end
      else
        -- just place the trunk
        place_if_air(world, int_x, int_y, place_z, Block.OAK_LOG)
      end
    end
  end
end

return update
