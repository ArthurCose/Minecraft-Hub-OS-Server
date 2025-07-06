local Block = require("scripts/minecraft/data/block")
local json = require("scripts/libs/json")

local Saves = {}

---@param world World
---@param interval number in seconds
---@param path string
function Saves.save_every(world, interval, path)
  local save_loop

  save_loop = function()
    Async.sleep(interval).and_then(function()
      print("Saving world...")

      local content = json.encode(world.data)

      Async.write_file(path, content).and_then(function()
        print("World saved")
        save_loop()
      end)
    end)
  end

  save_loop()
end

local function create_translator(old_dict, new_dict)
  local translator = {}

  for key, value in pairs(old_dict) do
    translator[value] = new_dict[key]
  end

  return translator
end

---@param world World
---@param path string
function Saves.load(world, path)
  Async.read_file(path).and_then(function(content)
    if content == "" then
      print(path .. " empty, continuing without loading")
      return
    end

    world.data = json.decode(content)

    local translator = create_translator(world.data.block_dictionary, Block)
    world.data.block_dictionary = Block

    -- translate using the block dictionary
    for layerIndex, layer in ipairs(world.data.blocks) do
      for rowIndex, row in ipairs(layer) do
        for col = 1, #layer do
          local new_id = translator[row[col]]

          if new_id == nil then
            local x = col - 1
            local y = rowIndex - 1
            local z = layerIndex * world.layer_diff

            print("Failed to translate " .. row[col] .. " at (" .. x .. ", " .. y .. ", " .. z .. ")")

            -- use an air block
            row[col] = Block.AIR
          else
            row[col] = new_id
          end
        end
      end
    end

    world:refresh()
  end)
end

return Saves
