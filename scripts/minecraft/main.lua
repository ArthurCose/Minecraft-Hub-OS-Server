local World = require("scripts/minecraft/world")
local Player = require("scripts/minecraft/player")
local Saves = require("scripts/minecraft/saves")

local world = World:new("default")
local players = {}

-- five minutes
Saves.save_every(world, 60 * 5, "world.json")
Saves.load(world, "world.json")

Net:on("tick", function()
  world:tick()

  for _, player in pairs(players) do
    player:tick()
  end
end)

Net:on("player_request", function(event)
  local player = Player:new(event.player_id)
  players[player.id] = player
  world:connect_player(player)
end)

Net:on("player_join", function(event)
  local player = players[event.player_id]

  player:handle_player_join()

  if player.instance then
    player.instance.world:handle_player_join(player)
  end
end)

Net:on("player_disconnect", function(event)
  local player = players[event.player_id]

  if player.instance then
    player.instance.world:disconnect_player(player)
  end

  players[player.id] = nil
end)

Net:on("actor_interaction", function(event)
  local player = players[event.player_id]
  player:handle_actor_interaction(event.actor_id, event.button)
end)

Net:on("tile_interaction", function(event)
  local player = players[event.player_id]
  player:handle_tile_interaction(event.x, event.y, event.z, event.button)
end)

Net:on("board_close", function(event)
  local player = players[event.player_id]
  player:handle_board_close()
end)

Net:on("player_move", function(event)
  local player = players[event.player_id]
  player:handle_player_move(event.x, event.y, event.z)
end)

Net:on("player_avatar_change", function(event)
  local player = players[event.player_id]
  player:handle_player_avatar_change(event)
end)

Net:on("player_emote", function(event)
  local player = players[event.player_id]

  if not player.instance then
    return
  end

  for _, p in pairs(player.instance.world.players) do
    p.instance:handle_player_emote(player, event.emote)
  end
end)
