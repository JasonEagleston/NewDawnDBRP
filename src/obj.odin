package main

import "core:sync"

Object :: struct {
    pos: [2]f32,
    tile_pos: [2]u16,
    z: ^Map,
    name: string,
    stats: map[string]int,
    move_vec: [2]int,
    move_vec_lock: sync.Mutex,
    
}

new_object :: proc() -> ^Object {
    obj := new(Object);
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