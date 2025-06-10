package main

Client :: struct {
    id: u64,
    mob: ^Object,
}

new_client :: proc(id: u64) -> ^Client {
    client := new(Client);
    client.id = id;
    return client;
}

serialize_client :: proc(buf: ^[dynamic]u8, client: ^Client) {
    from_u64(buf, client.id, -1)
}