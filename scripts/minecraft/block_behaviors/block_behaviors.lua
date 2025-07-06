local Block = require("scripts/minecraft/data/block")
local Tags = require("scripts/minecraft/data/tags")
local Liquids = require("scripts/minecraft/data/liquids")
local Helpers = require("scripts/minecraft/block_behaviors/helpers")

---@type table<Block, fun(world: World, int_x: number, int_y: number, int_z: number, block_id: number?)>
local BlockBehaviors = {
  [Block.GRASS_BLOCK] = require("scripts/minecraft/block_behaviors/grass_block"),
  [Block.OAK_SAPLING] = require("scripts/minecraft/block_behaviors/oak_sapling"),
}

-- leaves
local leaf_update = require("scripts/minecraft/block_behaviors/leaves")
local leaf_block_ids = Helpers.get_block_ids(Tags["#leaves"])

for _, block_id in ipairs(leaf_block_ids) do
  BlockBehaviors[block_id] = leaf_update
end

-- water
local water_update = require("scripts/minecraft/block_behaviors/liquid_water")

for _, block_id in ipairs(Liquids.Water) do
  BlockBehaviors[block_id] = water_update
end

-- lava
local lava_update = require("scripts/minecraft/block_behaviors/liquid_lava")

for _, block_id in ipairs(Liquids.Lava) do
  BlockBehaviors[block_id] = lava_update
end

return BlockBehaviors
