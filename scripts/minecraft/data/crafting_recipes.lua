local append_table = require("scripts/lib/append_table")

local CraftingRecipes = {
  Inventory = {
    { -- temporary recipe? stone cutter in the future
      result = { id = "STONE_BRICKS", count = 4 },
      required = { { id = "STONE", count = 4 } }
    },
    {
      result = { id = "CRAFTING_TABLE", count = 1 },
      required = { { id = "#planks", count = 4 } }
    },
    {
      result = { id = "OAK_PLANKS", count = 4 },
      required = { { id = "OAK_LOG", count = 1 } }
    },
    {
      result = { id = "BIRCH_PLANKS", count = 4 },
      required = { { id = "BIRCH_LOG", count = 1 } }
    },
    {
      result = { id = "SPRUCE_PLANKS", count = 4 },
      required = { { id = "SPRUCE_LOG", count = 1 } }
    },
    {
      result = { id = "JUNGLE_PLANKS", count = 4 },
      required = { { id = "JUNGLE_LOG", count = 1 } }
    },
    {
      result = { id = "DARK_OAK_PLANKS", count = 4 },
      required = { { id = "DARK_OAK_LOG", count = 1 } }
    },
    {
      result = { id = "ACACIA_PLANKS", count = 4 },
      required = { { id = "ACACIA_LOG", count = 1 } }
    },
    {
      result = { id = "STICK", count = 4 },
      required = { { id = "#planks", count = 2 } }
    },
  },
  CraftingTable = {
    {
      result = { id = "BUCKET", count = 1 },
      required = { { id = "IRON", count = 3 } }
    },
    { -- temporary recipe? (stone cutter in the future)
      result = { id = "OAK_STAIRS", count = 4 },
      required = { { id = "OAK_PLANKS", count = 6 } }
    },
    {
      result = { id = "OAK_SIGN", count = 1 },
      required = {
        { id = "OAK_PLANKS", count = 6 },
        { id = "STICK", count = 1 }
      }
    },
    {
      result = { id = "CHEST", count = 1 },
      required = { { id = "#planks", count = 8 } }
    },
    {
      result = { id = "FURNACE", count = 1 },
      required = { { id = "COBBLESTONE", count = 8 } }
    },
    {
      result = { id = "STONE_CUTTER", count = 1 },
      required = {
        { id = "STONE", count = 3 },
        { id = "IRON", count = 1 }
      }
    },
  },
  Furnace = {
    {
      result = { id = "IRON", count = 8 },
      required = {
        { id = "RAW_IRON", count = 8 },
        { id = "#coal", count = 1 }
      }
    },
    {
      result = { id = "IRON", count = 1 },
      required = {
        { id = "RAW_IRON", count = 1 },
        { id = "#planks", count = 1 }
      }
    },
    {
      result = { id = "GOLD", count = 8 },
      required = {
        { id = "RAW_GOLD", count = 8 },
        { id = "#coal", count = 1 }
      }
    },
    {
      result = { id = "GOLD", count = 1 },
      required = {
        { id = "RAW_GOLD", count = 1 },
        { id = "#planks", count = 1 }
      }
    },
    {
      result = { id = "COPPER", count = 8 },
      required = {
        { id = "RAW_COPPER", count = 8 },
        { id = "#coal", count = 1 }
      }
    },
    {
      result = { id = "COPPER", count = 1 },
      required = {
        { id = "RAW_COPPER", count = 1 },
        { id = "#planks", count = 1 }
      }
    },
    {
      result = { id = "STONE", count = 8 },
      required = {
        { id = "COBBLESTONE", count = 8 },
        { id = "#coal", count = 1 }
      }
    },
    {
      result = { id = "STONE", count = 1 },
      required = {
        { id = "COBBLESTONE", count = 1 },
        { id = "#planks", count = 1 }
      }
    },
    {
      result = { id = "GLASS", count = 8 },
      required = {
        { id = "SAND", count = 8 },
        { id = "#coal", count = 1 }
      }
    },
    {
      result = { id = "GLASS", count = 1 },
      required = {
        { id = "SAND", count = 1 },
        { id = "#planks", count = 1 }
      }
    },
    {
      result = { id = "CHARCOAL", count = 8 },
      required = {
        { id = "#logs", count = 8 },
        { id = "#coal", count = 1 }
      }
    },
    {
      result = { id = "CHARCOAL", count = 1 },
      required = {
        { id = "#logs", count = 1 },
        { id = "#planks", count = 1 }
      }
    },
  },
  StoneCutter = {
    {
      result = { id = "STONE_BRICKS", count = 1 },
      required = { { id = "STONE", count = 1 } }
    },
    {
      result = { id = "STONE_BRICKS", count = 8 },
      required = { { id = "STONE", count = 8 } }
    },
    {
      result = { id = "STONE_BRICK_STAIRS", count = 1 },
      required = { { id = "STONE_BRICKS", count = 1 } }
    },
    {
      result = { id = "STONE_BRICK_STAIRS", count = 8 },
      required = { { id = "STONE_BRICKS", count = 8 } }
    },
    {
      result = { id = "OAK_STAIRS", count = 1 },
      required = { { id = "OAK_PLANKS", count = 1 } }
    },
    {
      result = { id = "OAK_STAIRS", count = 8 },
      required = { { id = "OAK_PLANKS", count = 8 } }
    },
    {
      result = { id = "BIRCH_STAIRS", count = 1 },
      required = { { id = "BIRCH_PLANKS", count = 1 } }
    },
    {
      result = { id = "BIRCH_STAIRS", count = 8 },
      required = { { id = "BIRCH_PLANKS", count = 8 } }
    },
    {
      result = { id = "SPRUCE_STAIRS", count = 1 },
      required = { { id = "SPRUCE_PLANKS", count = 1 } }
    },
    {
      result = { id = "SPRUCE_STAIRS", count = 8 },
      required = { { id = "SPRUCE_PLANKS", count = 8 } }
    },
    {
      result = { id = "JUNGLE_STAIRS", count = 1 },
      required = { { id = "JUNGLE_PLANKS", count = 1 } }
    },
    {
      result = { id = "JUNGLE_STAIRS", count = 8 },
      required = { { id = "JUNGLE_PLANKS", count = 8 } }
    },
    {
      result = { id = "DARK_OAK_STAIRS", count = 1 },
      required = { { id = "DARK_OAK_PLANKS", count = 1 } }
    },
    {
      result = { id = "DARK_OAK_STAIRS", count = 8 },
      required = { { id = "DARK_OAK_PLANKS", count = 8 } }
    },
    {
      result = { id = "ACACIA_STAIRS", count = 1 },
      required = { { id = "ACACIA_PLANKS", count = 1 } }
    },
    {
      result = { id = "ACACIA_STAIRS", count = 8 },
      required = { { id = "ACACIA_PLANKS", count = 8 } }
    },
  }
}

append_table(CraftingRecipes.CraftingTable, CraftingRecipes.Inventory)

return CraftingRecipes
