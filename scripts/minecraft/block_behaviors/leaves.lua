local Block = require("scripts/minecraft/data/block")
local Tags = require("scripts/minecraft/data/tags")
local Helpers = require("scripts/minecraft/block_behaviors/helpers")
local includes = require("scripts/libs/includes")

-- 6 on java, 4 on bedrock, using bedrock rules for efficiency
local MAX_LOG_SEARCH = 4

local log_block_ids = Helpers.get_block_ids(Tags["#logs"])
local leaf_block_ids = Helpers.get_block_ids(Tags["#leaves"])

local function find_log(world, int_x, int_y, int_z)
  local visited_map = {}
  local test_next = {
    { int_x - 1, int_y,     int_z },
    { int_x + 1, int_y,     int_z },
    { int_x,     int_y - 1, int_z },
    { int_x,     int_y + 1, int_z },
    { int_x,     int_y,     int_z - 1 },
    { int_x,     int_y,     int_z + 1 },
  }

  local function add_to_next_test(test_pos)
    for _, pos in ipairs(visited_map) do
      if pos[1] == test_pos[1] and pos[2] == test_pos[2] and pos[3] == test_pos[3] then
        return true
      end
    end

    visited_map[#visited_map + 1] = test_pos
    test_next[#test_next + 1] = test_pos

    return false
  end

  local function test(test_pos)
    local test_x = test_pos[1]
    local test_y = test_pos[2]
    local test_z = test_pos[3]

    local block_id = world:get_block(test_x, test_y, test_z)

    if includes(log_block_ids, block_id) then
      return true
    end

    if not includes(leaf_block_ids, block_id) then
      return false
    end

    add_to_next_test({ test_x - 1, test_y, test_z })
    add_to_next_test({ test_x + 1, test_y, test_z })
    add_to_next_test({ test_x, test_y - 1, test_z })
    add_to_next_test({ test_x, test_y + 1, test_z })
    add_to_next_test({ test_x, test_y, test_z - 1 })
    add_to_next_test({ test_x, test_y, test_z + 1 })

    return false
  end

  local remaining_travel = MAX_LOG_SEARCH

  while remaining_travel > 0 do
    remaining_travel = remaining_travel - 1

    local current_test = test_next
    test_next = {}

    for _, test_pos in ipairs(current_test) do
      if test(test_pos) then
        return true
      end
    end
  end

  return false
end

local function update(world, int_x, int_y, int_z)
  if math.random(8) > 1 then
    -- slows down update speed, and this is prob an expensive update anyway so we want to reduce it
    return
  end

  if find_log(world, int_x, int_y, int_z) then
    return
  end

  -- decay
  world:set_block(int_x, int_y, int_z, Block.AIR)
end

return update
