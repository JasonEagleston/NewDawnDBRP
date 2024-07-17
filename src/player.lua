---@class Player
---@field obj Obj
Player = class(function(player, obj)
    player.obj = obj or Obj({ 0, 0 }, player)
end)
