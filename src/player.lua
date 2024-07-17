---@class Player
---@field id number
---@field name string
---@field obj Obj
Player = class(function(player, id, name, obj)
    player.obj = obj or Obj({ 0, 0 }, player)
end)

function Player:initial_sync()

end
