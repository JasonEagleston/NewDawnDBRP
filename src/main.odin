package main

import wsserver "../odin-wsserver"

import "core:sync"
import "core:fmt"
import "core:mem"

DEBUG := false;

GameState :: struct {
    clients: [dynamic]^Client,
    objects: map[u32]^Object,
    port: u16,
    maps: [dynamic]Map,
}

game_state := GameState {
    clients = {},
    objects = make(map[u32]^Object),
    port = 8080,
}

/*
On client login, send a confirmation packet and add them to the creation/load menu.
*/

add_client :: proc(client: wsserver.Client_Connection) {
    append(&game_state.clients, new_client(client))
    client_login(client);
}

remove_client :: proc(client: wsserver.Client_Connection) {
    logout := false;
    for i := 0; i < len(&game_state.clients); i += 1 {
        if (game_state.clients[i].id == client) {
            unordered_remove(&game_state.clients, i);
            logout = true;
            break;
        }
    }
    if (logout) { client_logout(client); }
}

get_client :: proc(client: wsserver.Client_Connection) -> ^Client {
    for c in game_state.clients {
        if c.id == client {
            return c;
        }
    }
    return nil;
}

message :: proc()

main :: proc() {

    init_races();
    append(&game_state.maps, create_map("maps/demo.tmj", "Demo"));
    append(&game_state.maps, create_map("maps/demo.tmj", "Demo 2"));

    server := wsserver.Server {
        host = "127.0.0.1",
        port = 8080,
        thread_loop = true,
        timeout_ms = 5000,
        evs = wsserver.Events {
            onopen = proc(client: wsserver.Client_Connection) {
                add_client(client)
                send_race_list(client);
                send_maps(client);
                sync_all_clients(client);
            },
            onclose = proc(client: wsserver.Client_Connection) {
                remove_client(client)
            },
            onmessage = proc(client: wsserver.Client_Connection, msg: []u8, type: wsserver.Frame_Type) {
                #partial switch(cast(PacketType)msg[0]) {
                    case PacketType.CLIENT_MOVE_REQUEST:
                        x := msg[1];
                        y := msg[2];
                        handle_client_move_request(client, x, y);
                        fmt.println(get_client(client).mob.move_vec);
                }
            }
        }
    }

    wsserver.listen(&server);
    
    for {

    }

}

