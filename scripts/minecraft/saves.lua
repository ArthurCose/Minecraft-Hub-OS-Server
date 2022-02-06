local Blocks = require("scripts/minecraft/data/blocks")
local json = require("scripts/libs/json")

local Saves = {}

function Saves.save_every(world, interval, path)
  local save_loop

  save_loop = function ()
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

function Saves.load(world, path)
  Async.read_file(path).and_then(function(content)
    if content == "" then
      print(path .. " empty, continuing without loading")
      return
    end

    world.data = json.decode(content)

    local translator = create_translator(world.data.block_dictionary, Blocks)

    -- translate using the block dictionary
    for _, layer in ipairs(world.data.blocks) do
      for _, row in ipairs(layer) do
        for col = 1, #layer do
          row[col] = translator[row[col]]
        end
      end
    end

    world:refresh()
  end)
end

return Saves
