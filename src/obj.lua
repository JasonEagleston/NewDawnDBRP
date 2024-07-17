---@class Obj
---@field pos integer[2]
---@field parent table? Optional parent.
Obj = class(function(obj, pos, parent)
    obj.pos = pos
    obj.parent = parent
end)

function Obj:move(game_state, x, y) end
