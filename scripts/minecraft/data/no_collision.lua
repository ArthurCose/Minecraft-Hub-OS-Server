local Blocks = require("scripts/minecraft/data/blocks")
local Liquids = require("scripts/minecraft/data/liquids")
local append_table = require("scripts/libs/append_table")

local NoCollision = {
  Blocks.AIR,
  Blocks.OAK_SAPLING,
  Blocks.OAK_SIGN_N,
  Blocks.OAK_SIGN_E,
  Blocks.OAK_SIGN_W,
  Blocks.OAK_SIGN_S
}

append_table(NoCollision, Liquids.All)

return NoCollision
