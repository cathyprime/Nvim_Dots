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

local get_code = function (bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    local str = table.concat(lines, "\n")
    local tbl = assert(loadstring(str))
end

-- {
--     command -> string,
--     args -> [string]?,
--     type -> (Dispatch|Start|Make)?, -- Dispatch if nil
--     compiler -> string?,
--     cwd -> string?,
--     env_vars -> [string, string]?
-- }
