local game_state = {}

---@class GameState
---@field maps Map[]
local GameState = {}

---@return GameState
function game_state.GameState:new()
    local o = {
        maps = {}
    }
    return o
end

return game_state
