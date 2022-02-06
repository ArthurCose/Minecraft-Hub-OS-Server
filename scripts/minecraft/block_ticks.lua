local Blocks = require("scripts/minecraft/data/blocks")

local BlockTicks = {
  [Blocks.GRASS_BLOCK] = require("scripts/minecraft/block_behaviors/grass_block"),
  [Blocks.OAK_SAPLING] = require("scripts/minecraft/block_behaviors/oak_sapling"),

  -- lava
  [Blocks.LAVA_FULL] = require("scripts/minecraft/block_behaviors/liquid_lava"),
  [Blocks.LAVA_4] = require("scripts/minecraft/block_behaviors/liquid_lava"),
  [Blocks.LAVA_3] = require("scripts/minecraft/block_behaviors/liquid_lava"),
  [Blocks.LAVA_2] = require("scripts/minecraft/block_behaviors/liquid_lava"),
  [Blocks.LAVA_1] = require("scripts/minecraft/block_behaviors/liquid_lava"),

  -- water
  [Blocks.WATER_FULL] = require("scripts/minecraft/block_behaviors/liquid_water"),
  [Blocks.WATER_8] = require("scripts/minecraft/block_behaviors/liquid_water"),
  [Blocks.WATER_7] = require("scripts/minecraft/block_behaviors/liquid_water"),
  [Blocks.WATER_6] = require("scripts/minecraft/block_behaviors/liquid_water"),
  [Blocks.WATER_5] = require("scripts/minecraft/block_behaviors/liquid_water"),
  [Blocks.WATER_4] = require("scripts/minecraft/block_behaviors/liquid_water"),
  [Blocks.WATER_3] = require("scripts/minecraft/block_behaviors/liquid_water"),
  [Blocks.WATER_2] = require("scripts/minecraft/block_behaviors/liquid_water"),
  [Blocks.WATER_1] = require("scripts/minecraft/block_behaviors/liquid_water"),
}

return BlockTicks
