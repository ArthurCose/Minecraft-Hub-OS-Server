local Blocks = require("scripts/minecraft/data/blocks")

local function update(world, int_x, int_y, int_z)
  if math.random(8) > 1 then
    return
  end

  local spread_x = int_x + math.random(3) - 2
  local spread_y = int_y + math.random(3) - 2
  local spread_z = int_z + (math.random(3) - 2) * world.layer_diff

  if world:get_block(spread_x, spread_y, spread_z) == Blocks.DIRT and world:get_block(spread_x, spread_y, spread_z + world.layer_diff) == Blocks.AIR then
    world:set_block(spread_x, spread_y, spread_z, Blocks.GRASS_BLOCK)
  end

  -- todo: death, need to handle transparent blocks
end

return update
