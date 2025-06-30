package main

ID_COUNTER: u32 = 0;

import "core:sync"
import "core:time"

Object :: struct {
    id: u32,
    pos: [2]f32,
    tile_pos: [2]u16,
    last_pos: [2]f32,
    last_tile_pos: [2]u16,
    z: ^Map,
    name: string,
    stats: Stats,
    keyed_stats: map[string]u64,
    move_vec: [2]int,
    move_vec_lock: sync.Mutex,
    tickable: bool,
}

serialize_object :: proc(buf: ^[dynamic]u8, obj: ^Object, serialize_stats: []string) {
    from_u16(buf, obj.tile_pos[0]);
    from_u16(buf, obj.tile_pos[1]);

    from_string(buf, obj.z.name);
    stat_map := stats_to_map(obj.stats);
    defer delete(stat_map);
    for key in serialize_stats {
        from_string(buf, key);
        if key not_in obj.keyed_stats {
            from_32(buf, stat_map[key]);
            continue;
        }
        from_64(buf, obj.keyed_stats[key]);
    }
}

new_object :: proc() -> ^Object {
    obj := new(Object);
    obj.id = ID_COUNTER;
    obj.pos = {0.0, 0.0};
    obj.tile_pos = {0, 0};
    ID_COUNTER += 1;

    add_object_gamestate(obj);
    

    return obj;  
}

free_object :: proc(obj: ^Object) {
    obj.z = nil;
}

set_move_vec :: proc(obj: ^Object, x, y: int) {
    sync.mutex_guard(&obj.move_vec_lock);
    obj.move_vec[0] = x;
    obj.move_vec[1] = y;
}

get_move_vec :: proc(obj: ^Object) -> [2]int {
    sync.mutex_guard(&obj.move_vec_lock);
    return { obj.move_vec[0], obj.move_vec[1] };
}

set_position :: proc(obj: ^Object, x, y: f32, z: ^Map) {
    if z != nil {
        change_map(obj, z);
        obj.z = z;
    }
    obj.pos[0] = x;
    obj.pos[1] = y;
    append(&game_state.moved_objects, obj.id);
    set_obj_position_map(z, obj, x, y);
}

can_move :: proc(obj: ^Object) -> bool {
    return true;
}

set_last_pos :: proc(obj: ^Object) {
    obj.last_pos[0] = obj.pos[0];
    obj.last_pos[1] = obj.pos[1];
    obj.last_tile_pos[0] = obj.tile_pos[0];
    obj.last_tile_pos[1] = obj.tile_pos[1];
}