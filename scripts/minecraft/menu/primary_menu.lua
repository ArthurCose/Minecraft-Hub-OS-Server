local MenuColors = require("scripts/minecraft/menu/menu_colors")
local InventoryMenu = require("scripts/minecraft/menu/inventory_menu")
local PlayerActions = require("scripts/minecraft/player_actions")

local PrimaryMenu = {}

function PrimaryMenu:new(player)
  local menu = {
    player = player
  }

  setmetatable(menu, self)
  self.__index = self

  return menu
end

function PrimaryMenu:open()
  local posts = {
    { id = "INVENTORY", read = true, title = "INVENTORY", author = "" },
    { id = "PUNCH", read = true, title = "PUNCH/FALL", author = "" },
    { id = "JUMP", read = true, title = "JUMP", author = "" },
    { id = "INTERACT", read = true, title = "INTERACT", author = "" },
  }

  local emitter = Net.open_board(self.player.id, "Actions", MenuColors.DEFAULT_COLOR, posts)

  emitter:on("post_selection", function(event)
    local post_id = event.post_id

    if post_id == "PUNCH" then
      self.player.action = PlayerActions.PUNCH
      self.player:close_menus()
    elseif post_id == "JUMP" then
      self.player.action = PlayerActions.JUMP
      self.player:close_menus()
    elseif post_id == "INVENTORY" then
      self.player:open_menu(InventoryMenu:new(self.player))
    elseif post_id == "INTERACT" then
      self.player.action = PlayerActions.INTERACT
      self.player:close_menus()
    end
  end)
end

function PrimaryMenu:update()
end

return PrimaryMenu
