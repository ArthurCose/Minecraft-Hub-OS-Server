local Block = require("scripts/minecraft/data/block")
local Liquids = require("scripts/minecraft/data/liquids")
local append_table = require("scripts/libs/append_table")

local NoCollision = {
  Block.AIR,
  Block.OAK_SAPLING,
  Block.OAK_SIGN_N,
  Block.OAK_SIGN_E,
  Block.OAK_SIGN_W,
  Block.OAK_SIGN_S,
  Block.LADDER_E,
  Block.LADDER_W,
  Block.LADDER_N,
  Block.LADDER_S,
}

append_table(NoCollision, Liquids.All)

return NoCollision
