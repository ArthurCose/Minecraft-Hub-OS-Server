local Block = require("scripts/minecraft/data/block")
local append_table = require("scripts/libs/append_table")
local includes = require("scripts/libs/includes")

local Liquids = {
  Water = {
    Block.WATER_FULL,
    Block.WATER_8,
    Block.WATER_7,
    Block.WATER_6,
    Block.WATER_5,
    Block.WATER_4,
    Block.WATER_3,
    Block.WATER_2,
    Block.WATER_1,
  },
  FlowingWater = {
    Block.WATER_FULL,
    Block.WATER_7,
    Block.WATER_6,
    Block.WATER_5,
    Block.WATER_4,
    Block.WATER_3,
    Block.WATER_2,
    Block.WATER_1,
  },
  Lava = {
    Block.LAVA_FULL,
    Block.LAVA_4,
    Block.LAVA_3,
    Block.LAVA_2,
    Block.LAVA_1,
  },
  FlowingLava = {
    Block.LAVA_FULL,
    Block.LAVA_3,
    Block.LAVA_2,
    Block.LAVA_1,
  },
  All = {},
  Flowing = {},
  Full = {
    Block.LAVA_FULL,
    Block.WATER_FULL
  },
  NonFull = {}
}

append_table(Liquids.All, Liquids.Water)
append_table(Liquids.All, Liquids.Lava)

append_table(Liquids.Flowing, Liquids.FlowingWater)
append_table(Liquids.Flowing, Liquids.FlowingLava)

for _, block_id in ipairs(Liquids.All) do
  if not includes(Liquids.Full, block_id) then
    Liquids.NonFull[#Liquids.NonFull + 1] = block_id
  end
end

return Liquids
