local fs = require("cathy.tasks.utils.fs")
local data = {}

local M = {
    types = {
        global = 0,
        tasks = 1,
        inputs = 2
    }
}

data = data or {
    [0] = {},
    [1] = {},
    [2] = {}
}

local run_task = function (task)
    local co = coroutine.wrap(task)
    return co()
end

function M.get(kind, name)
    if not kind and not name then
        return data
    end
    if not name then
        return data[kind]
    end
    if not data[kind] then
        data[kind] = {}
    end
    if not data[kind][name] and kind == M.types.tasks then
        data[kind][name] = fs.load_task(name)
    end
    return data[kind][name]
end

function M.run(kind, name)
    local task = M.get(kind, name)
    if task then
        return run_task(task)
    end
    return nil
end

function M.set(kind, name, value)
    if not data[kind] then
        data[kind] = {}
    end
    data[kind][name] = value
end

return M
