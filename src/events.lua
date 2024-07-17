---@module 'events'
local events = {}

local timer = require("timer")

---@class Event
---@field tick_time integer
---@field callback function
events.Event = {}
---@param tick_time integer Time when next tick occurs.
---@param callback function Callback function.
---@return Event
function events.Event:new(tick_time, callback)
    local o = {
        tick_time = tick_time,
        callback = callback,
    }
    setmetatable(o, self)
    self.__index = self
    o.tick_time = tick_time
    o.callback = callback
    return o
end

---@class EventHandler
---@field events [Event]
events.EventHandler = {}
---@return EventHandler
function events.EventHandler:new()
    local o = { events = {} }
    setmetatable(o, self)
    self.__index = self
    return o
end

function events.EventHandler:tick()
    local time = timer.get_time()
    for i = #self.events, 1, -1 do
        local event = self.events[i]
        if time >= event.tick_time then
            local retval = event.callback(self, event, time)
            if not retval == 1 then
                self.events[i] = nil
            end
        end
        i = i - 1
    end
end

return events
