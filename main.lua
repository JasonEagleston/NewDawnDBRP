local love = require("love")
local enet = require("enet")
local events = require("shared/events")

local client_connected = false
local host = enet.host_create()
local server = host:connect("localhost:5515")
local time = 0

function send_message(msg)
    if not client_connected then
        return 0
    end
    server:send(msg)
end

local event_handler = events.EventHandler:new()
local message_event = events.Event:new(0, function(handler, event, time)
    if time >= event.tick_time then
        event.tick_time = time + 1000
        send_message("TEST")
    end
    return 1
end)

table.insert(event_handler.events, message_event)

function love.update(dt)
    local event = host:service()
    while event do
        if event.type == "connect" then
            print("Connected.")
            client_connected = true
        elseif event.type == "disconnect" then
            print("Disconnected.")
            client_connected = false
        end
        event = host:service()
    end
    event_handler:tick()
end