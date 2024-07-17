local Obj = require("src/Obj")

local maps = {}

---@class Tile
---@field id integer
---@field objs Obj[]
local Tile = {}

function Tile:new(id)
    local o = {
        id = id,
        objs = {},
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

---@param obj Obj
function Tile:add_obj(obj)
    table.insert(self.objs, obj)
end

function Tile:remove_obj(obj)
    for i = #self.objs, 1, -1 do
        if self.objs[i] == obj then
            return table.remove(self.objs, i)
        end
    end
end

---@param obj Obj
---@return boolean
function Tile:has_obj(obj)
    for _, val in pairs(self.objs) do
        if val == obj then
            return true
        end
    end
    return false
end

---@class Map
---@field width integer
---@field height integer
---@field tiles [Tile]
local Map = {}

---@param width integer
---@param height integer
---@param tiles [Tile]
function Map:new(o, width, height, tiles)
    o = o or {
        width = width,
        height = height,
        tiles = tiles,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

---@param x integer
---@param y integer
---@return Tile
function Map:get_tile(x, y)
    return self.tiles[x + y * self.width]
end

function Map:add_obj() end

return maps
