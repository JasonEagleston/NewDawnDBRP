package main

import wsserver "../odin-wsserver"

import "core:mem"
import "core:fmt"
import "core:slice"
import "core:strings"

Packet :: struct {
    data: [dynamic]u8,
}

PacketType :: enum u8 {
    LOGIN = 1,
    LOGOUT = 2,
    RACES = 3,
    MAPS = 4,
    CLIENT_SYNC = 5,
    CLIENT_MOVE_REQUEST = 6, 
}

from_u64 :: proc(buf: ^[dynamic]u8, n: u64) {
    s := mem.any_to_bytes(n);
    for i := 0; i < 8; i += 1 {
        append(buf, s[i]);
    }
}
to_u64 :: proc(n: ^[8]u8) -> u64 {
    ret_val: u64 = 0;
    s := mem.any_to_bytes(ret_val)
    for i := 7; i >= 0; i -= 1 {
        s[i] = n[i];
    }
    
    return ret_val;
}
from_f32 :: proc(buf: ^[dynamic]u8, n: f32) {
    s := mem.any_to_bytes(n);
    for i := 0; i < size_of(f32); i += 1 {
        append(buf, s[i]);
    }
}
from_u16 :: proc(buf: ^[dynamic]u8, n: u16) -> int {
    s := mem.any_to_bytes(n);
    for i := 0; i < 2; i += 1 {
        append(buf, s[i]);
    }
    return 2;
}
from_string :: proc(buf: ^[dynamic]u8, s: string) -> int {
    old_len := len(buf);

    append(buf, cast(u8)len(s));
    for i := 0; i < len(s); i += 1 {
        append(buf, s[i]);
    }
    return len(buf) - old_len;

}
packet :: proc(init_size: int, type: PacketType) -> ^Packet {
    p := new(Packet);
    p.data = make([dynamic]u8, init_size);
    append(&p.data, cast(u8)type);
    
    return p;
}

free_packet :: proc(packet: ^Packet) {
    delete(packet.data);
    free(packet);
}



client_login :: proc(client: wsserver.Client_Connection) {
    p := packet(size_of(client), .LOGIN);
    from_u64(&p.data, client);
    broadcast(p);
    free_packet(p);


}

sync_all_clients :: proc(client: wsserver.Client_Connection) {
    p := packet(0, .CLIENT_SYNC);
    defer free_packet(p)
    for client in game_state.clients {
        serialize_client(&p.data, client);
    }
    msg_client(client, p);
}

sync_client :: proc(client: wsserver.Client_Connection, id: wsserver.Client_Connection) {
    p := packet(0, .CLIENT_SYNC);
    defer free_packet(p);
    for client in game_state.clients {
        if client.id == id {
            serialize_client(&p.data, client);
        }
    }
    msg_client(client, p);
}

client_logout :: proc(client: wsserver.Client_Connection) {
    p := packet(size_of(client), .LOGOUT)
    defer free_packet(p);
    from_u64(&p.data, client);
    broadcast(p);
}

msg_client :: proc(client: wsserver.Client_Connection, p: ^Packet) {
    wsserver.send_frame(client, p.data[:], .Binary);
}

broadcast :: proc(p: ^Packet) {
    wsserver.send_frame_broadcast(game_state.port, p.data[:], .Binary);
}

send_race_list :: proc(client: wsserver.Client_Connection) {
    p := packet(0, .RACES);
    defer free_packet(p);
    append(&p.data, cast(u8)len(races));
    for &race in races { 
        serialize_race(&p.data, &race);
    }
    msg_client(client, p);
}

send_maps :: proc(client: wsserver.Client_Connection) {
    p := packet(0, .MAPS);
    defer free_packet(p);
    for key, _map in game_state.maps {
        from_string(&p.data, _map.name);
        from_u16(&p.data, _map.width);
        from_u16(&p.data, _map.height);
        for tile in _map.tiles {
            from_u16(&p.data, tile.id);
        }
    }
    msg_client(client, p);
}

handle_client_move_request :: proc(client: wsserver.Client_Connection, x, y: u8) {
    set_move_vec(get_client(client).mob, cast(int)x, cast(int)y);
}