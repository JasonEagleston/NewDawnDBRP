local Obj = require("src/obj")
---@class Player
---@field obj Obj
local Player = {}

---@return Player
function Player:new()
    local o = {
        obj = Obj:new()
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

return Player
