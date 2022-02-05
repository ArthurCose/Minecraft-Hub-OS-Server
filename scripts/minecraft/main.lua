local World = require("scripts/minecraft/world")
local Player = require("scripts/minecraft/player")

local world = World:new("default")
local players = {}

function tick()
  world:tick()
end

function handle_player_request(player_id)
  local player = Player:new(player_id)
  players[player_id] = player
  world:connect_player(player)
end

function handle_player_join(player_id)
  local player = players[player_id]

  if player.instance then
    player.instance.world:handle_player_join(player)
  end
end

function handle_player_disconnect(player_id)
  local player = players[player_id]

  if player.instance then
    player.instance.world:disconnect_player(player)
  end

  players[player_id] = nil
end

function handle_actor_interaction(player_id, other_id, button)
  local player = players[player_id]
  player:handle_actor_interaction(other_id, button)
end

function handle_tile_interaction(player_id, x, y, z, button)
  local player = players[player_id]
  player:handle_tile_interaction(x, y, z, button)
end

function handle_post_selection(player_id, post_id)
  local player = players[player_id]
  player:handle_post_selection(post_id)
end

function handle_board_close(player_id)
  local player = players[player_id]
  player:handle_board_close()
end

function handle_player_move(player_id, x, y, z)
  local player = players[player_id]
  player:handle_player_move(x, y, z)
end

function handle_player_avatar_change(player_id, details)
  local player = players[player_id]
  player:handle_player_avatar_change(details)
end