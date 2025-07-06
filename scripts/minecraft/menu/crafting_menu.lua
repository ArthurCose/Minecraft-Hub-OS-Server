local CraftingUtil = require("scripts/minecraft/crafting_util")

---@class CraftingMenu
---@field player Player
---@field name string
---@field color Net.Color
---@field recipes CraftingRecipe[]
local CraftingMenu = {}

---@param player Player
---@param name string
---@param recipes CraftingRecipe[]
---@param color Net.Color
function CraftingMenu:new(player, name, color, recipes)
  local menu = {
    posts = nil,
    player = player,
    name = name,
    color = color,
    recipes = recipes
  }

  setmetatable(menu, self)
  self.__index = self

  return menu
end

function CraftingMenu:open()
  self.posts = {}

  CraftingUtil.generate_recipe_posts(self.recipes, self.player.items, self.posts)

  local emitter = Net.open_board(self.player.id, self.name, self.color, self.posts, true)

  emitter:on("post_selection", function(event)
    CraftingUtil.craft(self.recipes, self.player.items, event.post_id)
    self.player:close_menu()
  end)
end

function CraftingMenu:update()
end

return CraftingMenu
