package main

import wsserver "../odin-wsserver"

import "core:sync"
import "core:fmt"
import "core:mem"
import "core:time"
import "core:thread"


DEBUG := false;

server_thread: ^thread.Thread;

GameState :: struct {
    clients: [dynamic]^Client,
    objects: map[u32]^Object,
    tickables: [dynamic]^Object,
    port: u16,
    maps: map[string]Map,
    now: time.Time,
    moved_objects: [dynamic]u32,
    moved_maps: [dynamic]u32,
    mutex: sync.Mutex
}

game_state := GameState {
    clients = make([dynamic]^Client),
    objects = make(map[u32]^Object),
    port = 8080,
    moved_objects = make([dynamic]u32),
    moved_maps = make([dynamic]u32),
}

/*
On client login, send a confirmation packet and add them to the creation/load menu.
*/

add_client :: proc(client: wsserver.Client_Connection) {
    _client := new_client(client);
    append(&game_state.clients, _client);
    client_login(client);
    _client.mob = new_object();
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

    

    start_server :: proc(t: ^thread.Thread) {
        fmt.println("TEST")
        server := wsserver.Server {
            host = "127.0.0.1",
            port = 8080,
            thread_loop = false,
            timeout_ms = 5000,
            evs = wsserver.Events {
                onopen = proc(client: wsserver.Client_Connection) {
                    sync.mutex_guard(&game_state.mutex);
                    add_client(client);
                    send_race_list(client);
                    send_maps(client);
                    sync_all_clients(client);
                },
                onclose = proc(client: wsserver.Client_Connection) {
                    remove_client(client)
                },
                onmessage = proc(client: wsserver.Client_Connection, msg: []u8, type: wsserver.Frame_Type) {
                    if true {
                        return
                    }
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
                            stats := sub_stats(map_to_stats(&stat_map), races[race_id].stats);
                            stat_map = stats_to_map(stats);
                            used_points := 0;
                            for name in stat_names {
                                used_points += cast(int)stat_map[name];
                            }
                            if used_points > cast(int)races[race_id].points {
                                tell_client(client, "More points used than available.");
                                remove_client(client);
                                // Used too many points! Client error, cheating?
                                break
                            }
                            create_character(get_client(client), race_id, stats);
                    }
                }
            }
        }
        wsserver.listen(&server);
    }
    server_thread = thread.create(start_server);
    thread.start(server_thread);
    
    for {
        sync.mutex_guard(&game_state.mutex);
        game_state.now = time.now();
      /*  for id, obj in game_state.objects {
            move_vec := get_move_vec(obj);
            if !can_move(obj) || (move_vec[0] == 0 && move_vec[1] == 0) {continue;}
            set_position(obj, obj.pos[0] + 5.0 * cast(f32)move_vec[0], obj.pos[1] + 5.0 * cast(f32)move_vec[1], nil);
        }

        packet := packet(0, .UPDATE_OBJECT_POSITION);
        defer free_packet(packet);

        for id in game_state.moved_objects {
            obj := game_state.objects[id];
            from_32(&packet.data, id);
            moved_map := false;
            for i in 0..<len(game_state.moved_maps) {
                if game_state.moved_maps[i] == id {
                    moved_map = true;
                    unordered_remove(&game_state.moved_maps, i);
                }
            }
            from_32(&packet.data, 1 if moved_map else 0);
            from_32(&packet.data, obj.pos[0])
            from_32(&packet.data, obj.pos[1])
            if moved_map {
                from_string(&packet.data, obj.z.name);
            }
        }

       // broadcast(packet);

        clear(&game_state.moved_objects);*/
    }
}
