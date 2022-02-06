local Blocks = require("scripts/minecraft/data/blocks")
local append_table = require("scripts/libs/append_table")

local Liquids = {
  Water = {
    Blocks.WATER_FULL,
    Blocks.WATER_8,
    Blocks.WATER_7,
    Blocks.WATER_6,
    Blocks.WATER_5,
    Blocks.WATER_4,
    Blocks.WATER_3,
    Blocks.WATER_2,
    Blocks.WATER_1,
  },
  FlowingWater = {
    Blocks.WATER_FULL,
    Blocks.WATER_7,
    Blocks.WATER_6,
    Blocks.WATER_5,
    Blocks.WATER_4,
    Blocks.WATER_3,
    Blocks.WATER_2,
    Blocks.WATER_1,
  },
  Lava = {
    Blocks.LAVA_FULL,
    Blocks.LAVA_4,
    Blocks.LAVA_3,
    Blocks.LAVA_2,
    Blocks.LAVA_1,
  },
  FlowingLava = {
    Blocks.LAVA_FULL,
    Blocks.LAVA_3,
    Blocks.LAVA_2,
    Blocks.LAVA_1,
  },
  All = {},
  Flowing = {}
}

append_table(Liquids.All, Liquids.Water)
append_table(Liquids.All, Liquids.Lava)

append_table(Liquids.Flowing, Liquids.FlowingWater)
append_table(Liquids.Flowing, Liquids.FlowingLava)

return Liquids
