local Blocks = {
  DIRT = 0,
  GRASS = 1,
  MYCELIUM = 2,
  PODZOL = 3,

  BEDROCK = 8,
  DEEPSLATE = 9,
  STONE = 10,
  ANDESITE = 11,
  DYORITE = 12,
  GRANITE = 13,
  GRAVEL = 14,
  SAND = 15,

  AIR = 16,
  COBBLESTONE = 18,
  SANDSTONE = 23,

  OAK_LOG = 24,
  OAK_LEAVES = 25,
  BIRCH_LOG = 26,
  BIRCH_LEAVES = 27,
  SPRUCE_LOG = 28,
  SPRUCE_LEAVES = 29,
  JUNGLE_LOG = 30,
  JUNGLE_LEAVES = 31,

  DARK_OAK_LOG = 32,
  DARK_OAK_LEAVES = 33,
  ACACIA_LOG = 34,
  ACACIA_LEAVES = 35,

  COAL_ORE = 40,
  COPPER_ORE = 41,
  IRON_ORE = 42,
  GOLD_ORE = 43,
  EMERALD_ORE = 44,
  LAPIS_ORE = 45,
  REDSTONE_ORE = 46,
  DIAMOND_ORE = 47,

  CRAFTING_TABLE = 48,
  FURNACE = 49,
  CHEST = 50,
}

Blocks.Drops = {
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

Blocks.TileEntities = {
  Blocks.FURNACE,
  Blocks.CHEST
}

return Blocks
