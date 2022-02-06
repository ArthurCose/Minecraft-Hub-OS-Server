local Blocks = require("scripts/minecraft/data/blocks")
local Helpers = {}

function Helpers.place_if_air(world, int_x, int_y, int_z, block_id)
  if world:get_block(int_x, int_y, int_z) == Blocks.AIR then
    world:set_block(int_x, int_y, int_z, block_id)
  end
end

return Helpers
