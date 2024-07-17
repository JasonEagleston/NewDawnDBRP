function table.remove_val(t, v)
    for i = 1, #t do
        if t[i] == v then
            table.remove(t, i)
            break
        end
    end
end

function table.remove_vals(t, ...)
    for i, v in ipairs(arg) do
        table.remove_val(t, v)
    end
end

function table.has(t, val)
    for i, v in ipairs(t) do
        if v == val then return true end
    end
    return false
end

---@param orig any Original data being copied.
---@param discard_funcs? boolean Whether to ignore functions, used for serialization.
---@param discard_keys? boolean Whether to discard or keep the keys in the next args.
---@param keys? table<string>
function deepcopy(orig, discard_funcs, discard_keys, keys)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            if discard_funcs and type(orig_value) == "function" or discard_keys and table.has(keys, orig_key) or not discard_keys and not table.has(keys, orig_key) then
                goto continue
            end
            copy[deepcopy(orig_key)] = deepcopy(orig_value, keep_funcs)
            ::continue::
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
