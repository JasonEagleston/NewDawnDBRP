local server_config = require("server_config")
---@class love
local love = require("love")
local enet = require("enet")
local events = require("src/events")

local client_connected = false
local host = enet.host_create()
local server = host:connect(server_config.address .. ":" .. server_config.port)
local time = 0

---@class EventHandler
local event_handler = events.EventHandler:new()

function love.keypressed(key) end

---@param msg string Message to send to server.
function Send_Message(msg)
    if not client_connected then
        return 0
    end
    server:send(msg)
end

function love.update(dt)
    local event = host:service()
    while event do
        if event.type == "receive" then
        elseif event.type == "connect" then
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
