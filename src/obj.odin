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
    last_seen: map[u64]time.Time,
    last_change: time.Time,
    eye: u16, // Not necessarily client viewport eye.
    visible_objects: [2][dynamic]u32,
    visible_object_swap: bool
}

serialize_object :: proc(buf: ^[dynamic]u8, obj: ^Object, serialize_stats: []string) {
    from_32(buf, obj.id);
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
    obj.last_seen = make(map[u64]time.Time);
    ID_COUNTER += 1;

    add_object_gamestate(obj);
    

    return obj;  
}

free_object :: proc(obj: ^Object) {
    obj.z = nil;
    delete(obj.last_seen);
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

obj_seen :: proc(obj: ^Object, client: ^Client) {
    obj.last_seen[client.id] = time.now();
}

try_see :: proc(src: ^Object, target: ^Object) {
    
}

set_objs_in_eye :: proc(obj: ^Object) {
    last_visible_objects := get_objs_in_eye(obj);
    obj.visible_object_swap = !obj.visible_object_swap;
    visible_objects := get_objs_in_eye(obj);
    clear(&visible_objects);
    for x in -obj.eye..=obj.eye {
        for y in -obj.eye..=obj.eye {
            tile := get_tile(obj.z, obj.tile_pos - {x, y});
            for _obj in tile.contents {
                try_see(_obj, obj);
                append(&visible_objects, _obj.id);
            }
        }
    }

    new_objects := make([dynamic]u32);
    

}

get_objs_in_eye :: proc(obj: ^Object) -> [dynamic]u32 {
    return obj.visible_objects[obj.visible_object_swap ? 0 : 1];
}