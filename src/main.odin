package main

import wsserver "../odin-wsserver"

import "core:sync"
import "core:fmt"
import "core:mem"
import "core:time"

DEBUG := false;

GameState :: struct {
    clients: [dynamic]^Client,
    objects: map[u32]^Object,
    tickables: [dynamic]^Object,
    port: u16,
    maps: map[string]Map,
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
    _client := new_client(client);
    append(&game_state.clients, new_client(client))
    client_login(client);

    add_object_map(&game_state.maps["Demo"], _client.mob);
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

tell_client :: proc(client: wsserver.Client_Connection, msg: string) {
    return;
}

add_object_gamestate :: proc(obj: ^Object) {
    game_state.objects[obj.id] = obj;
}

remove_object_gamestate :: proc(obj: ^Object) {
    game_state.objects[obj.id] = nil;
}

get_client :: proc(client: wsserver.Client_Connection) -> ^Client {
    for c in game_state.clients {
        if c.id == client {
            return c;
        }
    }
    return nil;
}

get_ms :: proc(ms: i64) -> i64 {
    return 1000000 * ms;
}

sleep_ms :: proc(ms: i64) {
    time.sleep(time.Duration(get_ms(ms)));
}

main :: proc() {

    init_races();
    game_state.maps["Demo"] = create_map("maps/demo.tmj", "Demo");
    game_state.maps["Demo 2"] = create_map("maps/demo.tmj", "Demo 2");

    server := wsserver.Server {
        host = "127.0.0.1",
        port = 8080,
        thread_loop = true,
        timeout_ms = 5000,
        evs = wsserver.Events {
            onopen = proc(client: wsserver.Client_Connection) {
                add_client(client);
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
                    case PacketType.CREATION_STAT_SEND:
                        race_id := get_race_idx(msg[1]);
                        if (race_id == -1) {
                            // Malformed packet/race not found?
                            break
                        }
                        pos := 2;
                        stat_map := make(map[string]i64);
                        defer delete(stat_map)
                        for name in stat_names {
                            stat_map[name] = cast(i64)msg[pos];
                            pos += 1;
                        }
                        stats := stats_to_map(sub_stats(map_to_stats(&stat_map), races[race_id].stats));
                        used_points := 0;
                        for name in stat_names {
                            used_points += cast(int)stats[name];
                        }
                        if used_points > cast(int)races[race_id].points {
                            tell_client(client, "More points used than available.");
                            remove_client(client);
                            // Used too many points! Client error, cheating?
                            break
                        }

                }
            }
        }
    }

    wsserver.listen(&server);

    
    for {
        
    }
}

