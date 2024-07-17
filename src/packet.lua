---@class Packet
local buffer = require("string.buffer")
Packet = class(function(packet, send_to, packet_type, data)
    packet.send_to = send_to
    local buf = buffer.new(#data + 1)
    buf:put(packet_type)
    buf:put(data)
    packet.data = buf
end)

PacketType = {
    PLAYER_SYNC = 1,
}
