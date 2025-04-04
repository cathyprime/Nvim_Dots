local cache = {}

local run_task = function (task)
    local co = coroutine.wrap(task)
    return co()
end

local cache_ops = setmetatable({
    get = function (kind, name)
        if not kind and not name then
            return cache
        end
        if not name then
            return cache[kind]
        end
        if not cache[kind] then
            return nil
        end
        return cache[kind][name]
    end,
    set = function (kind, name, value)
        if not cache[kind] then
            cache[kind] = {}
        end
        cache[kind][name] = value
    end,
    inspect = function ()
        put(cache)
    end
}, {
    __call = function (_, kind, name)
        if not cache[kind] then
            return nil
        end
        if not cache[kind][name] then
            return nil
        end
        if not type(cache[kind][name]) == "function" then
            return nil
        end
        return run_task(cache[kind][name])
    end
})

local tasks_dir = vim.fn.stdpath("data") .. "/tasks/"

local encode_path = function (str)
    return str:gsub("/", [[%%]])
end

local task_dir = function (path)
    return tasks_dir .. encode_path(path) .. "/"
end

local make_dir = function (path)
    local dir = task_dir(path)
    if not vim.uv.fs_stat(dir) then
        vim.fn.mkdir(dir, "p")
    end
end

local get_tasks = function (path)
    local dir_name = task_dir(path)
    if not vim.uv.fs_stat(dir_name) and not vim.fn.isdirectory(dir_name) then
        return nil
    end

    return vim.iter(vim.fs.dir(dir_name))
        :map(function (k, v) return vim.fn.fnamemodify(k, ":r") end)
        :totable()
end

local open_task_window = function (bufnr, name, size)
    size = size or 0.70

    local columns = vim.opt.columns:get()
    local lines = vim.opt.lines:get()
    local i_size = (1 - size) / 2

    local height = math.floor(lines   * size)
    local width  = math.floor(columns * size)
    local row    = math.floor(lines   * i_size)
    local col    = math.floor(columns * i_size)

    vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "single",
        title = name,
        title_pos = "center"
    })
end

local create_task_buffer = function ()
    return vim.api.nvim_create_buf(false, true)
end

local prepare_buffer = function (opts)
    vim.bo[opts.bufnr].ft = "lua"
    vim.keymap.set("n", "q", function()
        local ok, _ = pcall(vim.cmd.close)
        if not ok then
            vim.cmd.bdelete()
        end
    end,
    {
        buffer = opts.bufnr,
        silent = true,
        noremap = true,
        nowait = true,
    })
    vim.api.nvim_create_autocmd({ "BufDelete", "BufHidden" }, {
        buffer = opts.bufnr,
        once = true,
        callback = function ()
            local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, true)
            -- save_task(cwd, lines)
            local str = table.concat(lines, "\n")
            local f = assert(loadstring(str), "failed to compile code")
            cache_ops.set("tasks", opts.name, f)
        end
    })
end

return {
    prepare_buffer = prepare_buffer,
    encode_path = encode_path,
    run_task = run_task,
    task_dir = task_dir,
    make_dir = make_dir,
    get_tasks = get_tasks,
    open_task_window = open_task_window,
    create_task_buffer = create_task_buffer,
    cache = cache_ops
}
