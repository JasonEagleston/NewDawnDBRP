---@class Event
---@field tick_time integer
---@field callback function
Event = class(function(event, tick_time, callback)
    event.tick_time = tick_time
    event.callback = callback
end)

---@class EventHandler
---@field events table<Event>
EventHandler = class(function(event_handler)
    event_handler.events = {}
end)

function EventHandler:add_event(event)
    table.insert(self.events, event)
end

function EventHandler:tick()
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
