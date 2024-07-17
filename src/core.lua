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

function deepcopy(orig, keep_funcs)
    local orig_type = type(orig)
    local copy
    if orig_type == "function" and not keep_funcs then
        return "_F"
    end
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            if type(orig_value) == "function" and not keep_funcs then
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
