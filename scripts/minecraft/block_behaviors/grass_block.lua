local Block = require("scripts/minecraft/data/block")
local NoCollision = require("scripts/minecraft/data/no_collision")
local includes = require("scripts/libs/includes")

local function update(world, int_x, int_y, int_z)
  if math.random(8) > 1 then
    return
  end

  local block_above = world:get_block(int_x, int_y, int_z + world.layer_diff)

  if not includes(NoCollision, block_above) then
    -- solid block above, return to dirt
    world:set_block(int_x, int_y, int_z, Block.DIRT)
    return
  end

  local spread_x = int_x + math.random(3) - 2
  local spread_y = int_y + math.random(3) - 2
  local spread_z = int_z + (math.random(4) - 3) * world.layer_diff

  local spread_block = world:get_block(spread_x, spread_y, spread_z)
  local block_above_spread = world:get_block(spread_x, spread_y, spread_z + world.layer_diff)

  if spread_block == Block.DIRT and includes(NoCollision, block_above_spread) then
    world:set_block(spread_x, spread_y, spread_z, Block.GRASS_BLOCK)
  end

  -- todo: death, need to handle transparent blocks
end

return update
