local regen_recov_func = function(n, points, add, stat_range)
    local new = n + add * 0.2
    if new < stat_range[1] or new > stat_range[2] then
        return n, points
    end
    return new, points + add
end
return {
    address = "localhost",
    port = "5515",
    creation = { -- Settings for the Creation menu.
        stats = {
            points = 50,
            energy = 1.0,
            strength = 1.0,
            force = 1.0,
            offense = 1.0,
            defense = 1.0,
            durability = 1.0,
            resistance = 1.0,
            regeneration = 1.0,
            recovery = 1.0,
            anger = 1.0
        },
        stat_range = {
            default = { 1.0, 3.0 },
            energy = { 1.0, 2.5 },
            anger = { 1.0, 2.0 },
        },
        add_functions = {
            default = function(n, points, add, stat_range)
                local new = n + add * 0.1
                if new < stat_range[1] or new > stat_range[2] then
                    return n, points
                end
                return new, points + add
            end,
            regeneration = regen_recov_func,
            recovery = regen_recov_func
        },
        races = { -- Stats are overriden - meaning any not defined remain default.
            alien = {
                stats = {
                    points = 97,
                    energy = 0.7,
                    strength = 0.5,
                    force = 0.5,
                    offense = 0.5,
                    defense = 0.5,
                    durability = 0.5,
                    resistance = 0.5,
                    regeneration = 0.4,
                    recovery = 0.4,
                    anger = 0.2
                },
                stat_range = {
                    default = { 0.5, 3.5 },
                    energy = { 0.7, 3.0 },
                    anger = { 0.2, 3.0 }
                },
                spawn_points = { "earth", "namek", "vegeta" }
            },
            human = {
                stats = {
                    points = 65
                },
                spawn_points = { "earth" }
            },
            namekian = {
                add_functions = {
                    anger = function(n, points, add, stat_range)
                        local new = n + add * 0.05
                        if new < stat_range[1] or new > stat_range[2] then
                            return n, points
                        end
                        return new, points + add
                    end
                },
                stats = {
                    points = 48,
                    energy = 1.35,
                    durability = 1.2,
                    resistance = 1.2,
                    regeneration = 1.4,
                    recovery = 1.4,
                    anger = 0.4,
                },
                spawn_points = { "namek" }
            },
            saiyan = {
                stats = {

                },
                spawn_points = { "vegeta" }
            },
        }
    }
}
