---@class GameState
---@field players Player[]
---@field maps Map[]
---@field packets Packet[]
GameState = class(function(game_state)
    game_state.players = {}
    game_state.maps = {}
    game_state.packets = {}
end)

function GameState:add_player(peer)
    local player = Player(peer:connect_id(), "")
    table.insert(self.players, player)
    table.insert(self.packets, Packet("broadcast", PacketType.PLAYER_SYNC, deepcopy(player, false)))
end

function GameState:remove_player(player)
    table.remove_val(self.players, player)
end
