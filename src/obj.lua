---@class Obj
---@field pos [integer, integer]
---@field parent table Optional parent.
local Obj = {}

function Obj:new(o, parent)
    o = o or {
        pos = { 0, 0 },
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Obj:move(game_state, x, y) end

return Obj
