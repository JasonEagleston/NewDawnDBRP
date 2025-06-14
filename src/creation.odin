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

stats_to_map :: proc(stats: ^Stats) {
    return {
        "strength" = stats.strength,
        "durability" = stats.durability,
        "speed" = stats.speed,
        "force" = stats.force,
        "recovery" = stats.recovery
    }
}

races : [dynamic]Race = nil;

serialize_race 

init_races :: proc() {
    if data, ok := os.read_entire_file("races.json"); ok {
        defer delete(data);
        _p, err := json.parse(data);
        parsed: json.Object = _p.(json.Object);
        defer delete(parsed);

        if err != .None {
            fmt.println("Error loading races.");
        }

        for name, _stats in parsed {
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