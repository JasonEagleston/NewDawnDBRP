package main

import "core:sync"

Object :: struct {
    x: f32,
    y: f32,
    name: string,
    stats: [dynamic]Map,
    move_vec: [2]int,
    move_vec_lock: sync.Mutex
}

new_object :: proc() -> ^Object {
    obj := new(Object);
    return obj;   
}

set_move_vec :: proc(obj: ^Object, x, y: int) {
    sync.mutex_guard(&obj.move_vec_lock);
    obj.move_vec[0] = x;
    obj.move_vec[1] = y;
}