local tasks_dir = vim.fn.stdpath("data") .. "/tasks/"
local M = {}

function M.encode_path(str)
    return str:gsub("/", [[_]])
end

function M.task_dir(path)
    return tasks_dir .. M.encode_path(path) .. "/"
end

function M.make_dir(path)
    local dir = M.task_dir(path)
    if not vim.uv.fs_stat(dir) then
        vim.fn.mkdir(dir, "p")
    end
    return dir
end

function M.task_file(cwd, name)
    return M.make_dir(cwd) .. name .. ".lua"
end

function M.load_task(name)
    local file = M.task_file(require("cathy.scopes").get_root(), name)
    if not vim.uv.fs_stat(file) then
        return
    end
    return assert(loadfile(file), "failed to compile")
end

function M.get_tasks(path)
    local dir_name = M.task_dir(path)
    if not vim.uv.fs_stat(dir_name) and not vim.fn.isdirectory(dir_name) then
        return nil
    end

    return vim.iter(vim.fs.dir(dir_name))
        :map(function (k, v)
            return vim.fn.fnamemodify(k, ":r")
        end)
end

function M.save_task(name, cwd, lines)
    local dir = M.make_dir(cwd)
    local file = dir .. name .. ".lua"
    vim.fn.writefile(lines, file)
end

return M
