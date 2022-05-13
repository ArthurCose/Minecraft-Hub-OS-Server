local CraftingUtil = require("scripts/minecraft/crafting_util")

local CraftingMenu = {}

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

  local emitter = Net.open_board(self.player.id, self.name, self.color, self.posts)

  emitter:on("post_selection", function(event)
    CraftingUtil.craft(self.recipes, self.player.items, event.post_id)
    self.player:close_menus()
  end)
end

function CraftingMenu:update()
end

return CraftingMenu
