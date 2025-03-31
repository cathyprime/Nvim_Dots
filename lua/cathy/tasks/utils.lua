local data = vim.fn.stdpath("data") .. "/tasks/"

vim.fn.mkdir(data, "p")

local get_path = function ()
    return tostring(vim.uv.cwd())
end

local encode_path = function (str)
    return str:gsub("/", [[%%]])
end

local tasks_file_name = function (str)
    if not str then
        return data .. encode_path(get_path()) .. ".lua"
    end
    return data .. encode_path(str) .. ".lua"
end

local load_tasks_file = function ()
    local f = assert(loadfile(tasks_file_name()))
    return f()
end

local write_task = function (task)
    vim.fn.writefile(task, tasks_file_name())
end

local task = {
    [[return {]],
    [[	cmd = "make",]],
    [[	args = { "-C", "out" },]],
    [[	compiler = "gcc",]],
    [[	dir = "~/polygon/acorn-lsp/acorn-transpiler/"]],
    [[}]]
}
