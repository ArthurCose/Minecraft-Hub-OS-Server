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

function Saves.load(world, path)
  Async.read_file(path).and_then(function(content)
    if content == "" then
      print(path .. " empty, continuing without loading")
      return
    end

    world.data = json.decode(content)
    world:refresh()
  end)
end

return Saves
