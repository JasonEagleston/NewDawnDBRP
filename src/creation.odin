package main

import "core:encoding/json"
import "core:fmt"
import "core:os"

Race :: struct {
    name: string,
    stats: Stats,
    max_stats: Stats,
    points: u8,
}

Stats :: struct {
    strength: f32,
    durability: f32,
    speed: f32,
    force: f32,
    resistance: f32,
    recovery: f32,
    energy: f32
}

stats_to_map :: proc(stats: ^Stats) -> map[string]f32 {
    stat_map := make(map[string]f32);
    stat_map["strength"] = stats.strength
    stat_map["durability"] = stats.durability;
    stat_map["force"] = stats.force;
    stat_map["resistance"] = stats.resistance;
    stat_map["speed"] = stats.speed;
    stat_map["recovery"] = stats.recovery;
    stat_map["energy"] = stats.energy;
    return stat_map;
}

races : [dynamic]Race = nil;

serialize_race :: proc(buf: ^[dynamic]u8, race: ^Race) {
    from_string(buf, race.name);
    append(buf, race.points);

    insert_from :: proc(buf: ^[dynamic]u8, stats: ^Stats) {
        stat_map := stats_to_map(stats);
        defer delete(stat_map);
        from_f32(buf, stat_map["strength"]);
        from_f32(buf, stat_map["durability"]);
        from_f32(buf, stat_map["force"]);
        from_f32(buf, stat_map["resistance"]);
        from_f32(buf, stat_map["speed"]);
        from_f32(buf, stat_map["recovery"]);
        from_f32(buf, stat_map["energy"]);
    }

    insert_from(buf, &race.stats);
    insert_from(buf, &race.max_stats);
}   

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
            stats := _stats.(json.Object);
            append(&races, Race {
                name = name,
                stats = {
                    strength = cast(f32)stats["strength"].(json.Array)[0].(json.Float),
                    durability = cast(f32)stats["durability"].(json.Array)[0].(json.Float),
                    speed = cast(f32)stats["speed"].(json.Array)[0].(json.Float),
                    force = cast(f32)stats["force"].(json.Array)[0].(json.Float),
                    resistance = cast(f32)stats["resistance"].(json.Array)[0].(json.Float),
                    recovery = cast(f32)stats["recovery"].(json.Array)[0].(json.Float),
                    energy = cast(f32)stats["energy"].(json.Array)[0].(json.Float),
                },
                max_stats = {
                    strength = cast(f32)stats["strength"].(json.Array)[1].(json.Float),
                    durability = cast(f32)stats["durability"].(json.Array)[1].(json.Float),
                    speed = cast(f32)stats["speed"].(json.Array)[1].(json.Float),
                    force = cast(f32)stats["force"].(json.Array)[1].(json.Float),
                    resistance = cast(f32)stats["resistance"].(json.Array)[1].(json.Float),
                    recovery = cast(f32)stats["recovery"].(json.Array)[1].(json.Float),
                    energy = cast(f32)stats["energy"].(json.Array)[1].(json.Float),
                },
                points = cast(u8)stats["points"].(json.Float)
            });
        }
    }
}