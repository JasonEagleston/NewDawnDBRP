package main

import "core:encoding/json"
import "core:fmt"
import "core:os"

Race :: struct {
    name: string,
}

Stats :: struct {
    strength: int,
    durability: int,
    speed: int,
    force: int,
    recovery: int
}

races : []Race = {
    Race {
        "Alien"
    },
    Race {
        "Demon"
    },
    Race {
        "God"
    },
    Race {
        "Human",
    },
}

init_races :: proc() {
    if data, ok := os.read_entire_file("races.json"); ok {
        defer delete(data);
        parser := json.make_parser(data);
        parsed_races: = json.parse_object(&parser);
        for race, s in cast(map[string]map[string]int)parsed_races {
            fmt.println(race);
        }
    } 
}