local Blocks = require("scripts/minecraft/data/blocks")

local BlockLoot = {
  [Blocks.DIRT] = { "DIRT" },
  [Blocks.GRASS_BLOCK] = { "DIRT" },
  [Blocks.DIRT_PATH] = { "DIRT" },
  [Blocks.MYCELIUM] = { "DIRT" },
  [Blocks.PODZOL] = { "DIRT" },

  [Blocks.BEDROCK] = {},
  [Blocks.DEEPSLATE] = {},
  [Blocks.STONE] = { "COBBLESTONE" },
  [Blocks.ANDESITE] = { "ANDESITE" },
  [Blocks.DYORITE] = { "DYORITE" },
  [Blocks.GRANITE] = { "GRANITE" },
  [Blocks.GRAVEL] = { "GRAVEL" },
  [Blocks.SAND] = { "SAND" },

  [Blocks.AIR] = {},
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
  [Blocks.LADDER_E] = { "LADDER" },
  [Blocks.LADDER_W] = { "LADDER" },
  [Blocks.LADDER_N] = { "LADDER" },
  [Blocks.LADDER_S] = { "LADDER" },

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
  [Blocks.FURNACE_E] = { "FURNACE" },
  [Blocks.FURNACE_N] = { "FURNACE" },
  [Blocks.CHEST_E] = { "CHEST" },
  [Blocks.CHEST_N] = { "CHEST" },
  [Blocks.CHEST] = { "CHEST" },
  [Blocks.STONE_CUTTER] = { "STONE_CUTTER" },

  [Blocks.LAVA_4] = {},
  [Blocks.LAVA_3] = {},
  [Blocks.LAVA_2] = {},
  [Blocks.LAVA_1] = {},
  [Blocks.LAVA_FULL] = {},
  [Blocks.OBSIDIAN] = { "OBSIDIAN" },
  [Blocks.WATER_FULL] = {},

  [Blocks.WATER_8] = {},
  [Blocks.WATER_7] = {},
  [Blocks.WATER_6] = {},
  [Blocks.WATER_5] = {},
  [Blocks.WATER_4] = {},
  [Blocks.WATER_3] = {},
  [Blocks.WATER_2] = {},
  [Blocks.WATER_1] = {},

  [Blocks.OAK_SAPLING] = { "OAK_SAPLING" },
  [Blocks.GLASS] = {},

  [Blocks.OAK_PLANKS] = { "OAK_PLANKS" },
  [Blocks.OAK_STAIRS_E] = { "OAK_STAIRS" },
  [Blocks.OAK_STAIRS_N] = { "OAK_STAIRS" },
  [Blocks.OAK_STAIRS_W] = { "OAK_STAIRS" },
  [Blocks.OAK_STAIRS_S] = { "OAK_STAIRS" },
  [Blocks.OAK_SIGN_E] = { "OAK_SIGN" },
  [Blocks.OAK_SIGN_W] = { "OAK_SIGN" },
  [Blocks.OAK_SIGN_N] = { "OAK_SIGN" },
  [Blocks.OAK_SIGN_S] = { "OAK_SIGN" },

  [Blocks.STONE_BRICKS] = { "STONE_BRICKS" },
  [Blocks.STONE_BRICK_STAIRS] = { "STONE_BRICK_STAIRS" },
}

for block_name, block_id in pairs(Blocks) do
  if BlockLoot[block_id] == nil then
    print("Missing BlockLoot definition for " .. block_name)
  end
end

return BlockLoot
