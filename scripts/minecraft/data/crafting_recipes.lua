local CraftingRecipes = {
  Inventory = {
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
      result = { id = "STICKS", count = 4 },
      required = { { id = "#planks", count = 2 } }
    },
  },
  CraftingTable = {
    {
      result = { id = "CHEST", count = 1 },
      required = { { id = "#planks", count = 8 } }
    },
    {
      result = { id = "FURNACE", count = 1 },
      required = { { id = "COBBLESTONE", count = 8 } }
    },
  },
  Furnace = {
    {
      result = { id = "IRON", count = 1 },
      required = {
        { id = "RAW_IRON", count = 1 },
        { id = "#fuel", count = 1 }
      }
    },
    {
      result = { id = "GOLD", count = 1 },
      required = {
        { id = "RAW_GOLD", count = 1 },
        { id = "#fuel", count = 1 }
      }
    },
    {
      result = { id = "COPPER", count = 1 },
      required = {
        { id = "RAW_COPPER", count = 1 },
        { id = "#fuel", count = 1 }
      }
    },
    {
      result = { id = "STONE", count = 1 },
      required = {
        { id = "COBBLESTONE", count = 1 },
        { id = "#fuel", count = 1 }
      }
    },
    {
      result = { id = "GLASS", count = 1 },
      required = {
        { id = "SAND", count = 1 },
        { id = "#fuel", count = 1 }
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
}

return CraftingRecipes
