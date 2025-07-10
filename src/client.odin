package main

import "core:fmt"

Client :: struct {
    id: u64,
    mob: ^Object,
}

new_client :: proc(id: u64) -> ^Client {
    client := new(Client);
    client.id = id;
    client.mob = nil;
    return client;
}

serialize_client :: proc(buf: ^[dynamic]u8, client: ^Client) {
    from_64(buf, client.id);
}

seen_objects :: proc(client: ^Client) {
    if client.mob == nil {
        return;
    }
    for 
}