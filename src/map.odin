package main

import "core:fmt"
import "core:os"
import "core:encoding/json"
import "core:math"

TILE_SIZE := 32;


Tile :: struct {
    id: u16,
    density: u8,
    contents: [dynamic]^Object // Every tile will have its own contents for now. In the future, move to larger sets of tiles to avoid excessive memory use; unimportant for prototyping.
}

Map :: struct {
    name: string,
    width: u16,
    height: u16,
    tiles: [dynamic]Tile,
    objects: [dynamic]^Object
}

get_tiles_from_map :: proc(_map: json.Object) -> [dynamic]Tile {
    _tiles := make([dynamic]Tile, cast(int)(_map["width"].(json.Float) * _map["height"].(json.Float)));
    for _l in _map["layers"].(json.Array) {
        layer := _l.(json.Object);
        count := 0;
        for _t in layer["data"].(json.Array) {
            tile := cast(u16)_t.(json.Float) - 1; // Tiled starts tiles at 1, we use 0.
            
            _tiles[count] = Tile {
                id = tile,
                density = 0,
                contents = make([dynamic]^Object)
            }
            count += 1;
        }
    }

    return _tiles;
}
create_map :: proc(load_map: string, name: string) -> Map {
    data, ok := os.read_entire_file(load_map);
    defer delete(data);
    _p, err := json.parse(data);
    parsed: json.Object = _p.(json.Object);
    defer delete(parsed);

    x, y :u16 = cast(u16)parsed["width"].(json.Float), cast(u16)parsed["height"].(json.Float);

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

get_tile :: proc(_map: ^Map, x: u16, y: u16) -> ^Tile {
    return &_map.tiles[(x - 1) + (y - 1) * _map.width];
}

add_object_map :: proc(_map: ^Map, obj: ^Object) {
    if (obj == nil) {
        log_error("Tried to add nil object to map.");
        return;
    }
   // set_position(obj, 0.0, 0.0, _map);
 //   append(&_map.objects, obj);
}

set_obj_position_map :: proc(_map: ^Map, obj: ^Object, x, y: f32) {
    cur_tile_pos: [2]u16 = {obj.tile_pos[0], obj.tile_pos[1]};
    new_tile_pos: [2]u16 = {cast(u16)math.trunc(x / 32), cast(u16)math.trunc(y / 32)};
}

set_obj_position :: proc(obj: ^Object, x, y: f32) {
    
}
