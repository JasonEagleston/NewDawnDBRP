package main

ID_COUNTER: u32 = 0;

import "core:sync"

Object :: struct {
    id: u32,
    pos: [2]f32,
    tile_pos: [2]u16,
    z: ^Map,
    name: string,
    stats: Stats,
    keyed_stats: map[string]u64,
    move_vec: [2]int,
    move_vec_lock: sync.Mutex,
    tickable: bool
}

serialize_object :: proc(buf: ^[dynamic]u8, obj: ^Object, serialize_stats: []string) {
    from_u16(buf, obj.tile_pos[0]);
    from_u16(buf, obj.tile_pos[1]);

    from_string(buf, obj.z.name);
    stat_map := stats_to_map(&obj.stats);
    for key in serialize_stats {
        from_string(buf, key);
        if key not_in obj.keyed_stats {
            from_u64(buf, stat_map[key]);
            continue;
        }
        from_u64(buf, obj.keyed_stats[key]);
    }
}

new_object :: proc() -> ^Object {
    obj := new(Object);
    obj.id = ID_COUNTER;
    ID_COUNTER += 1;
    

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

set_position :: proc(obj: ^Object, x, y: f32, z: ^Map) {
    if z != nil {
        obj.z = z;
    }
    obj.pos[0] = x;
    obj.pos[1] = y;
    set_obj_position_map(z, obj, x, y);
}