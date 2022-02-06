local CraftingUtil = require("scripts/minecraft/crafting_util")

local CraftingMenu = {}

function CraftingMenu:new(player, name, color, recipes)
  local menu = {
    posts = {},
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
  CraftingUtil.generate_recipe_posts(self.recipes, self.player.items, self.posts)

  Net.open_board(self.player.id, self.name, self.color, self.posts)
end

function CraftingMenu:update()
end


function CraftingMenu:handle_selection(post_id)
  CraftingUtil.craft(self.recipes, self.player.items, post_id)
  self.player:close_menus()
end

return CraftingMenu
