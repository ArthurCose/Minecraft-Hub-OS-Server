local Block = require("scripts/minecraft/data/block")

---@type table<Block, (string | nil)[]>
local BlockLoot = {
  [Block.DIRT] = { "DIRT" },
  [Block.GRASS_BLOCK] = { "DIRT" },
  [Block.DIRT_PATH] = { "DIRT" },
  [Block.MYCELIUM] = { "DIRT" },
  [Block.PODZOL] = { "DIRT" },

  [Block.BEDROCK] = {},
  [Block.DEEPSLATE] = {},
  [Block.STONE] = { "COBBLESTONE" },
  [Block.ANDESITE] = { "ANDESITE" },
  [Block.DYORITE] = { "DYORITE" },
  [Block.GRANITE] = { "GRANITE" },
  [Block.GRAVEL] = { "GRAVEL" },
  [Block.SAND] = { "SAND" },

  [Block.AIR] = {},
  [Block.COBBLESTONE] = { "COBBLESTONE" },
  [Block.SANDSTONE] = { "SANDSTONE" },

  [Block.OAK_LOG] = { "OAK_LOG" },
  [Block.OAK_LEAVES] = { nil, nil, nil, nil, nil, "OAK_SAPLING" },
  [Block.BIRCH_LOG] = { "BIRCH_LOG" },
  [Block.BIRCH_LEAVES] = { nil, nil, nil, nil, nil, "BIRCH_SAPLING" },
  [Block.SPRUCE_LOG] = { "SPRUCE_LOG" },
  [Block.SPRUCE_LEAVES] = { nil, nil, nil, nil, nil, "SPRUCE_SAPLING" },
  [Block.JUNGLE_LOG] = { "JUNGLE_LOG" },
  [Block.JUNGLE_LEAVES] = { nil, nil, nil, nil, nil, "JUNGLE_SAPLING" },

  [Block.DARK_OAK_LOG] = { "DARK_OAK_LOG" },
  [Block.DARK_OAK_LEAVES] = { nil, nil, nil, nil, nil, "DARK_OAK_SAPLING" },
  [Block.ACACIA_LOG] = { "ACACIA_LOG" },
  [Block.ACACIA_LEAVES] = { nil, nil, nil, nil, nil, "ACACIA_SAPLING" },
  [Block.LADDER_E] = { "LADDER" },
  [Block.LADDER_W] = { "LADDER" },
  [Block.LADDER_N] = { "LADDER" },
  [Block.LADDER_S] = { "LADDER" },

  [Block.COAL_ORE] = { "COAL" },
  [Block.COPPER_ORE] = { "RAW_COPPER" },
  [Block.IRON_ORE] = { "RAW_IRON" },
  [Block.GOLD_ORE] = { "RAW_GOLD" },
  [Block.EMERALD_ORE] = { "EMERALD" },
  [Block.LAPIS_ORE] = { "LAPIS" },
  [Block.REDSTONE_ORE] = { "REDSTONE" },
  [Block.DIAMOND_ORE] = { "DIAMOND" },

  [Block.CRAFTING_TABLE] = { "CRAFTING_TABLE" },
  [Block.FURNACE] = { "FURNACE" },
  [Block.FURNACE_E] = { "FURNACE" },
  [Block.FURNACE_N] = { "FURNACE" },
  [Block.CHEST_E] = { "CHEST" },
  [Block.CHEST_N] = { "CHEST" },
  [Block.CHEST] = { "CHEST" },
  [Block.STONE_CUTTER] = { "STONE_CUTTER" },

  [Block.LAVA_4] = {},
  [Block.LAVA_3] = {},
  [Block.LAVA_2] = {},
  [Block.LAVA_1] = {},
  [Block.LAVA_FULL] = {},
  [Block.OBSIDIAN] = { "OBSIDIAN" },
  [Block.WATER_FULL] = {},

  [Block.WATER_8] = {},
  [Block.WATER_7] = {},
  [Block.WATER_6] = {},
  [Block.WATER_5] = {},
  [Block.WATER_4] = {},
  [Block.WATER_3] = {},
  [Block.WATER_2] = {},
  [Block.WATER_1] = {},

  [Block.OAK_SAPLING] = { "OAK_SAPLING" },
  [Block.GLASS] = {},

  [Block.OAK_PLANKS] = { "OAK_PLANKS" },
  [Block.OAK_STAIRS_E] = { "OAK_STAIRS" },
  [Block.OAK_STAIRS_N] = { "OAK_STAIRS" },
  [Block.OAK_STAIRS_W] = { "OAK_STAIRS" },
  [Block.OAK_STAIRS_S] = { "OAK_STAIRS" },
  [Block.OAK_SIGN_E] = { "OAK_SIGN" },
  [Block.OAK_SIGN_W] = { "OAK_SIGN" },
  [Block.OAK_SIGN_N] = { "OAK_SIGN" },
  [Block.OAK_SIGN_S] = { "OAK_SIGN" },

  [Block.STONE_BRICKS] = { "STONE_BRICKS" },
  [Block.STONE_BRICK_STAIRS] = { "STONE_BRICK_STAIRS" },
}

for block_name, block_id in pairs(Block) do
  if BlockLoot[block_id] == nil then
    print("Missing BlockLoot definition for " .. block_name)
  end
end

return BlockLoot
