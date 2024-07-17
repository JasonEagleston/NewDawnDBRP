local server_config = require("server_config")

local enet = require("enet")
local events = require("src/events")
local timer = require("timer")

local last_tick = 0
local tick_time = 15
local time = timer.get_time()

local host = enet.host_create(server_config.address .. ":" .. server_config.port)

while true do
    last_tick = time
    time = timer.get_time()
    local dt = (time - last_tick) / 1000
    local event = host:service()
    while event do
        if event.type == "receive" then
            print("Received message: ", event.data, event.peer)
        elseif event.type == "connect" then
            print(event.peer, "connected.")
        elseif event.type == "disconnect" then
            print(event.peer, "disconnected.")
        end
        event = host:service()
    end
    timer.sleep(tick_time)
end
