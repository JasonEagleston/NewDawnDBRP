package main

BoundBox :: struct {
    pos: [2]f32,
    size: [2]f32
}

new_bound_box :: proc {
    new_bound_box_xy,
    new_bound_box_array,
}

new_bound_box_xy :: proc(x: f32, y: f32, xs: f32, ys: f32) -> BoundBox {
    return BoundBox { pos = {x, y}, size = {xs, ys} };
}

new_bound_box_array :: proc(pos: [2]f32, size: [2]f32) {
    return BoundBox { pos, size };
}

bound_box_collides :: proc {
    bound_box_collides_box,
    bound_Box_collides_xy,
}

bound_box_collides_box :: proc(a, b: BoundBox) {
    return a.pos[0] < b.pos[0] + b.size[0] && a.pos[0] + a.size[0] > b.pos[0] && a.pos[1] < b.pos[1] + b.size[1] && a.pos[1] + a.size[1] > b.pos[1];
}

bound_box_collides_xy :: proc(a: BoundBox, x: f32, y: f32, xs: f32, ys: f32) {
    return bound_box_collides_box(&a, new_bound_box_xy(x, y, xs, ys));
}
