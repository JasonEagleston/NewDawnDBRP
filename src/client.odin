package main

import "core:fmt"

Client :: struct {
    id: u64,
    mob: ^Object,
}

new_client :: proc(id: u64) -> ^Client {
    client := new(Client);
    client.id = id;
    client.mob = new_object();
    return client;
}

serialize_client :: proc(buf: ^[dynamic]u8, client: ^Client) {
    from_u64(buf, client.id, -1);
}