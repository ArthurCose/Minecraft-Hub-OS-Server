local MenuColors = require("scripts/minecraft/menu/menu_colors")
local CraftingMenu = require("scripts/minecraft/menu/crafting_menu")
local CraftingRecipes = require("scripts/minecraft/data/crafting_recipes")
local InventoryUtil = require("scripts/minecraft/inventory_util")
local PlayerActions = require("scripts/minecraft/player_actions")

local InventoryMenu = {}

function InventoryMenu:new(player)
  local posts = {
    { id = "CRAFT", read = true, title = "CRAFT", author = "" }
  }

  InventoryUtil.generate_item_posts(player.items, posts)

  return {
    open = function()
      Net.open_board(player.id, "Inventory", MenuColors.DEFAULT_COLOR, posts)
    end,

    update = function() end,

    handle_selection = function(self, post_id)
      if post_id == "CRAFT" then
        player:open_menu(CraftingMenu:new(player, "Craft", MenuColors.DEFAULT_COLOR, CraftingRecipes.Inventory))
      else
        -- selecting an item
        for i, item in ipairs(player.items) do
          if item.id == post_id then
            player.selected_item = item
            player.action = PlayerActions.ITEM

            -- move to top
            table.remove(player.items, i)
            table.insert(player.items, 1, item)
            break
          end
        end

        player:close_menus()
      end
    end
  }
end

return InventoryMenu
