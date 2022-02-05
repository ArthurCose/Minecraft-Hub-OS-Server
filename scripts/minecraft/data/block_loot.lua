local Blocks = require("scripts/minecraft/data/blocks")

local BlockLoot = {
  [Blocks.DIRT] = { "DIRT" },
  [Blocks.GRASS] = { "DIRT" },
  [Blocks.MYCELIUM] = { "DIRT" },
  [Blocks.PODZOL] = { "DIRT" },

  [Blocks.BEDROCK] = { nil },
  [Blocks.DEEPSLATE] = { nil },
  [Blocks.STONE] = { "COBBLESTONE" },
  [Blocks.ANDESITE] = { "ANDESITE" },
  [Blocks.DYORITE] = { "DYORITE" },
  [Blocks.GRANITE] = { "GRANITE" },
  [Blocks.GRAVEL] = { "GRAVEL" },
  [Blocks.SAND] = { "SAND" },

  [Blocks.AIR] = { nil },
  [Blocks.COBBLESTONE] = { "COBBLESTONE" },
  [Blocks.SANDSTONE] = { "SANDSTONE" },

  [Blocks.OAK_LOG] = { "OAK_LOG" },
  [Blocks.OAK_LEAVES] = { nil, nil, nil, nil, nil, "OAK_SAPLING" },
  [Blocks.BIRCH_LOG] = { "BIRCH_LOG" },
  [Blocks.BIRCH_LEAVES] = { nil, nil, nil, nil, nil, "BIRCH_SAPLING" },
  [Blocks.SPRUCE_LOG] = { "SPRUCE_LOG" },
  [Blocks.SPRUCE_LEAVES] = { nil, nil, nil, nil, nil, "SPRUCE_SAPLING" },
  [Blocks.JUNGLE_LOG] = { "JUNGLE_LOG" },
  [Blocks.JUNGLE_LEAVES] = { nil, nil, nil, nil, nil, "JUNGLE_SAPLING" },

  [Blocks.DARK_OAK_LOG] = { "DARK_OAK_LOG" },
  [Blocks.DARK_OAK_LEAVES] = { nil, nil, nil, nil, nil, "DARK_OAK_SAPLING" },
  [Blocks.ACACIA_LOG] = { "ACACIA_LOG" },
  [Blocks.ACACIA_LEAVES] = { nil, nil, nil, nil, nil, "ACACIA_SAPLING" },

  [Blocks.COAL_ORE] = { "COAL" },
  [Blocks.COPPER_ORE] = { "RAW_COPPER" },
  [Blocks.IRON_ORE] = { "RAW_IRON" },
  [Blocks.GOLD_ORE] = { "RAW_GOLD" },
  [Blocks.EMERALD_ORE] = { "EMERALD" },
  [Blocks.LAPIS_ORE] = { "LAPIS" },
  [Blocks.REDSTONE_ORE] = { "REDSTONE" },
  [Blocks.DIAMOND_ORE] = { "DIAMOND" },

  [Blocks.CRAFTING_TABLE] = { "CRAFTING_TABLE" },
  [Blocks.FURNACE] = { "FURNACE" },
  [Blocks.CHEST] = { "CHEST" },
}

return BlockLoot
