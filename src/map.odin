package main

import "core:os"
import "core:encoding/json"

TileType :: enum {

}

Tile :: struct {
    id: u16,
    density: u8,
    type: TileType,
    contents: [dynamic]^Object
}

Map :: struct {
    name: string,
    width: int,
    height: int,
    tiles: []Tile,
    movables: [dynamic]^Object
}

get_tiles_from_map :: proc(^[]u8) -> []Tile {
    return {}

}

get_size_from_map :: proc(^[]u8) -> (int, int) {
    return 0, 0;
}

create_map :: proc(load_map: string) -> Map {

    data, ok := os.read_entire_file(load_map);

    defer delete(data, context.allocator);

    x, y := get_size_from_map(&data);

    _map := Map {
        load_map,
        x,
        y,
        get_tiles_from_map(&data),
        {},
    }
    
    return _map;
}

get_tile :: proc(_map: Map, x: int, y: int) -> ^Tile {
    return &_map.tiles[(x - 1) + (y - 1) * _map.width];
}