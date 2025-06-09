package main

import "core:fmt"
import "core:os"
import "core:encoding/json"


Tile :: struct {
    id: u16,
    density: u8,
    contents: [dynamic]^Object // Every tile will have its own contents for now. In the future, move to larger sets of tiles to avoid excessive memory use; unimportant for prototyping.
}

Map :: struct {
    name: string,
    width: int,
    height: int,
    tiles: [dynamic]Tile,
    movables: [dynamic]^Object
}

get_tiles_from_map :: proc(_map: json.Object) -> [dynamic]Tile {
    _tiles := make([dynamic]Tile, cast(int)(_map["width"].(json.Float) * _map["height"].(json.Float)));
    for _l in _map["layers"].(json.Array) {
        layer := _l.(json.Object);
        count := 0;
        for _t in layer["data"].(json.Array) {
            tile := cast(u16)_t.(json.Float);
            
            _tiles[count] = Tile {
                id = tile,
                density = 0,
                contents = make([dynamic]^Object)
            }
            count += 1;
        }
    }

    if DEBUG {
        fmt.println(_tiles);
    }

    return _tiles;

}

create_map :: proc(load_map: string, name: string) -> Map {

    data, ok := os.read_entire_file(load_map);
    defer delete(data);

    _p, err := json.parse(data);
    parsed: json.Object = _p.(json.Object);
    defer delete(parsed);

    x, y :int = cast(int)parsed["width"].(json.Float), cast(int)parsed["height"].(json.Float);

    _map := Map {
        name,
        x,
        y,
        get_tiles_from_map(parsed),
        {},
    }
    
    return _map;
}

free_map :: proc() {

}

get_tile :: proc(_map: ^Map, x: int, y: int) -> ^Tile {
    return &_map.tiles[(x - 1) + (y - 1) * _map.width];
}