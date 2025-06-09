package main

import "core:encoding/json"
import "core:fmt"
import "core:os"

Race :: struct {
    name: string,
    stats: Stats
}

Stats :: struct {
    strength: int,
    durability: int,
    speed: int,
    force: int,
    recovery: int
}

races : [dynamic]Race = nil;

init_races :: proc() {
    if data, ok := os.read_entire_file("races.json"); ok {
        defer delete(data);
        parsed, err := json.parse(data);
        defer delete(parsed.(json.Object));

        if err != .None {
            fmt.println("Error loading races.");
        }

        for name, _stats in parsed.(json.Object) {
            stats := transmute(map[string]int)_stats.(json.Object);
            append(&races, Race {
                name = name,
                stats = {
                    strength = stats["strength"],
                    durability = stats["durability"],
                    speed = stats["speed"],
                    force = stats["force"],
                    recovery = stats["recovery"]
                }
            });
        }
    }
}