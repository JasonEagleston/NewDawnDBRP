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