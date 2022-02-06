local MenuColors = require("scripts/minecraft/menu/menu_colors")
local InventoryUtil = require("scripts/minecraft/inventory_util")

local ChestInventorySubmenu = {}

function ChestInventorySubmenu:new(player, tile_entity)
  local menu = {
    posts = {},
    player = player,
    tile_entity = tile_entity
  }

  setmetatable(menu, self)
  self.__index = self

  return menu
end

function ChestInventorySubmenu:open()
  InventoryUtil.generate_item_posts(self.player.items, self.posts)

  Net.open_board(self.player.id, "Inventory", MenuColors.DEFAULT_COLOR, self.posts)
end

function ChestInventorySubmenu:update()
  if self.tile_entity.deleted then
    self.player:close_menus()
    return
  end

  InventoryUtil.sync_inventory_menu(self.player, self.player.items, self.posts, 0)
end

function ChestInventorySubmenu:handle_selection(post_id)
  if self.tile_entity.deleted then
    -- just exit the menu if the chest is gone
    self.player:close_menus()
  else
    -- move one item into the chest
    local items = self.tile_entity.data.items

    if InventoryUtil.remove_item(self.player.items, post_id) then
      InventoryUtil.add_item(items, post_id)
      InventoryUtil.sync_inventory_menu(self.player, self.player.items, self.posts, 0)
    end
  end
end

return ChestInventorySubmenu
