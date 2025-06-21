package main

import "core:encoding/json"
import "core:fmt"
import "core:os"

stat_names := []string{"strength", "durability", "force", "resistance", "speed", "recovery", "energy"};

race_id_count: u8 = 0;

Race :: struct {
    name: string,
    stats: Stats,
    max_stats: Stats,
    points: u8,
    id: u8
}

Stats :: struct {
    strength: i64,
    durability: i64,
    speed: i64,
    force: i64,
    resistance: i64,
    recovery: i64,
    energy: i64
}

stats_to_map :: proc(stats: Stats) -> map[string]i64 {
    stat_map := make(map[string]i64);
    stat_map["strength"] = stats.strength
    stat_map["durability"] = stats.durability;
    stat_map["force"] = stats.force;
    stat_map["resistance"] = stats.resistance;
    stat_map["speed"] = stats.speed;
    stat_map["recovery"] = stats.recovery;
    stat_map["energy"] = stats.energy;
    return stat_map;
}

map_to_stats :: proc(stat_map: ^map[string]i64) -> Stats {
    return Stats {
        strength = stat_map["strength"],
        durability = stat_map["durability"],
        force = stat_map["force"],
        resistance = stat_map["resistance"],
        speed = stat_map["speed"],
        recovery = stat_map["recovery"],
        energy = stat_map["energy"]
    };    
}

add_stats :: proc(a, b: Stats) -> Stats {
    return Stats {
        strength = a.strength + b.strength,
        durability = a.durability + b.durability,
        force = a.force + b.force,
        resistance = a.resistance + b.resistance,
        speed = a.speed + b.speed,
        recovery = a.recovery + b.recovery,
        energy = a.energy + b.energy
    }
}

sub_stats :: proc(a, b: Stats) -> Stats {
    return add_stats(a, flip_stat(b));
}

flip_stat :: proc(a: Stats) -> Stats {
    return Stats {
        strength = -a.strength,
        durability = -a.durability,
        force = -a.force,
        resistance = -a.resistance,
        speed = -a.speed,
        recovery = -a.recovery,
        energy = -a.energy
    }
}

races : [dynamic]Race = nil;

get_race_idx :: proc(id: u8) -> int {
    for i in 0..<len(races) {
        if races[i].id == id {
            return i;
        }
    }
    return -1;
}

serialize_race :: proc(buf: ^[dynamic]u8, race: ^Race) {
    from_string(buf, race.name);
    append(buf, race.points);
    append(buf, race.id);

    insert_from :: proc(buf: ^[dynamic]u8, stats: Stats) {
        stat_map := stats_to_map(stats);
        defer delete(stat_map);
        for name in stat_names {
            from_64(buf, stat_map[name])
        }
    }

    insert_from(buf, race.stats);
    insert_from(buf, race.max_stats);
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
                    strength = cast(i64)stats["strength"].(json.Array)[0].(json.Float),
                    durability = cast(i64)stats["durability"].(json.Array)[0].(json.Float),
                    speed = cast(i64)stats["speed"].(json.Array)[0].(json.Float),
                    force = cast(i64)stats["force"].(json.Array)[0].(json.Float),
                    resistance = cast(i64)stats["resistance"].(json.Array)[0].(json.Float),
                    recovery = cast(i64)stats["recovery"].(json.Array)[0].(json.Float),
                    energy = cast(i64)stats["energy"].(json.Array)[0].(json.Float),
                },
                max_stats = {
                    strength = cast(i64)stats["strength"].(json.Array)[1].(json.Float),
                    durability = cast(i64)stats["durability"].(json.Array)[1].(json.Float),
                    speed = cast(i64)stats["speed"].(json.Array)[1].(json.Float),
                    force = cast(i64)stats["force"].(json.Array)[1].(json.Float),
                    resistance = cast(i64)stats["resistance"].(json.Array)[1].(json.Float),
                    recovery = cast(i64)stats["recovery"].(json.Array)[1].(json.Float),
                    energy = cast(i64)stats["energy"].(json.Array)[1].(json.Float),
                },
                points = cast(u8)stats["points"].(json.Float),
                id = race_id_count
            });
            race_id_count += 1;
        }
    }
}