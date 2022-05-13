local MenuColors = require("scripts/minecraft/menu/menu_colors")
local ChestInventorySubmenu = require("scripts/minecraft/menu/chest_inventory_submenu")
local InventoryUtil = require("scripts/minecraft/inventory_util")

local ChestMenu = {}

function ChestMenu:new(player, tile_entity)
  local menu = {
    posts = nil,
    player = player,
    tile_entity = tile_entity
  }

  setmetatable(menu, self)
  self.__index = self

  return menu
end

function ChestMenu:open()
  if not self.tile_entity.data.items then
    self.tile_entity.data.items = {}
  end

  self.posts = {
    { id = "INVENTORY", read = true, title = "INVENTORY", author = "" }
  }

  InventoryUtil.generate_item_posts(self.tile_entity.data.items, self.posts)

  local emitter = Net.open_board(self.player.id, "Chest", MenuColors.CHEST_COLOR, self.posts)

  emitter:on("post_selection", function(event)
    local post_id = event.post_id

    if self.tile_entity.deleted then
      -- just exit the menu if the chest is gone
      self.player:close_menus()
    elseif post_id == "INVENTORY" then
      self.player:open_menu(ChestInventorySubmenu:new(self.player, self.tile_entity))
    else
      -- take one item out of the chest
      local items = self.tile_entity.data.items

      if InventoryUtil.remove_item(items, post_id) then
        InventoryUtil.add_item(self.player.items, post_id)
        InventoryUtil.sync_inventory_menu(self.player, self.tile_entity.data.items, self.posts, 1)
      end
    end
  end)
end

function ChestMenu:update()
  if self.tile_entity.deleted then
    self.player:close_menus()
    return
  end

  InventoryUtil.sync_inventory_menu(self.player, self.tile_entity.data.items, self.posts, 1)
end

return ChestMenu
