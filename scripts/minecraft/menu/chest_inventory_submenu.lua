local MenuColors = require("scripts/minecraft/menu/menu_colors")
local InventoryUtil = require("scripts/minecraft/inventory_util")

---@class ChestInventorySubmenu
---@field posts Net.BoardPost[]
---@field player Player
---@field tile_entity TileEntity
local ChestInventorySubmenu = {}

---@param player Player
---@param tile_entity TileEntity
function ChestInventorySubmenu:new(player, tile_entity)
  local menu = {
    posts = nil,
    player = player,
    tile_entity = tile_entity
  }

  setmetatable(menu, self)
  self.__index = self

  return menu
end

function ChestInventorySubmenu:open()
  self.posts = {}
  InventoryUtil.generate_item_posts(self.player.items, self.posts)

  local emitter = Net.open_board(self.player.id, "Inventory", MenuColors.DEFAULT_COLOR, self.posts, true)
  emitter:on("post_selection", function(event)
    if self.tile_entity.deleted then
      -- just exit the menu if the chest is gone
      self.player:close_menus()
    else
      -- move one item into the chest
      local items = self.tile_entity.data.items

      if InventoryUtil.remove_item(self.player.items, event.post_id) then
        InventoryUtil.add_item(items, event.post_id)
        InventoryUtil.sync_inventory_menu(self.player, self.player.items, self.posts, 0)
      end
    end
  end)
end

function ChestInventorySubmenu:update()
  if self.tile_entity.deleted then
    self.player:close_menus()
    return
  end

  InventoryUtil.sync_inventory_menu(self.player, self.player.items, self.posts, 0)
end

return ChestInventorySubmenu
