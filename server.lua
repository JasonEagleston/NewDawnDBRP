local server_config = require("server_config")
require("src/core")
require("src/packet")
require("src/class")
require("src/player")
require("src/game_state")
local bitser = require("bitser/bitser")
local buffer = require("string.buffer")
local enet = require("enet")
local events = require("src/events")
local timer = require("timer")
local zen = require("luazen")

local last_tick = 0
local tick_time = 15
local time = timer.get_time()

local host = enet.host_create(server_config.address .. ":" .. server_config.port)

local game_state = GameState()

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
            game_state:add_player(event.peer)
        elseif event.type == "disconnect" then
            print(event.peer, "disconnected.")
        end
        event = host:service()
    end
    timer.sleep(tick_time)
end
