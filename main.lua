local server_config = require("server_config")
timer = require("timer")

require("src/class")
require("src/obj")
require("src/events")
require("src/player")
require("src/maps")

local bitser = require("bitser/bitser")
local enet = require("enet")
local events = require("src/events")
---@class love
local love = require("love")
local nuklear = require("nuklear")
local zen = require("luazen")

local client_connected = false
local host = enet.host_create()
server_config.address = "127.0.0.1"
local server = host:connect(server_config.address .. ":" .. server_config.port)
local time = 0

local ui
local open_uis = { "main_menu" }

function table.remove_val(t, v)
    for i = 1, #t do
        if t[i] == v then
            table.remove(t, i)
            break
        end
    end
end

function Quit_Game()
    os.exit(0, true)
end

local ui_data = {

}

local ui_callback = {
    main_menu = function()
        local width, height = love.graphics.getDimensions()
        if ui:windowBegin("", width / 2 - 100, height / 2 - 150, 200, 300) then
            ui:layoutRow('dynamic', 32, { 0.75, 0.25 })
            if ui_data["main_menu"] == nil then
                ui_data["main_menu"] = { address = { value = "localhost" }, port = { value = "5515" } }
            end
            ui:edit('field', ui_data["main_menu"].address)
            ui:edit('field', ui_data["main_menu"].port)
            ui:layoutRow('dynamic', 32, 1)
            ui:button("Connect")
            if ui:button("Settings") then
                table.remove_val(open_uis, "main_menu")
                table.insert(open_uis, "settings")
            end
            if ui:button("Quit") then
                Quit_Game()
            end
        end
        ui:windowEnd()
    end,
    settings = function()
        local width, height = love.graphics.getDimensions()
        if ui:windowBegin("", width / 2 - 100, height / 2 - 150, 200, 300) then
            ui:layoutRow('dynamic', 32, 1)
            if ui:button("Back") then
                table.remove_val(open_uis, "settings")
                table.insert(open_uis, "main_menu")
            end
        end
        ui:windowEnd()
    end
}

---@class EventHandler
local event_handler = EventHandler()

---@param msg string Message to send to server.
function Send_Message(msg)
    if not client_connected then
        return 0
    end
    server:send(msg)
end

function love.load()
    ui = nuklear.newUI()
    love.window.setVSync(-1)
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
    ui:frameBegin()
    for _, ui in pairs(open_uis) do
        ui_callback[ui]()
    end
    ui:frameEnd()
end

function love.draw()
    ui:draw()
end

function love.keypressed(key, scancode, isrepeat)
    ui:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    ui:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
    ui:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    ui:mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    ui:mousemoved(x, y, dx, dy, istouch)
end

function love.textinput(text)
    ui:textinput(text)
end

function love.wheelmoved(x, y)
    ui:wheelmoved(x, y)
end
