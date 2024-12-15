local M = {
    actions = {}
}

local cached_mappings = {}

local Path = require("plenary.path")
local home = os.getenv("HOME")
local prefix = ""

function M.set_prefix(str)
    vim.validate({
        str = { str, "string" }
    })
    prefix = str .. " "
end

function M.actions.abort()
    vim.api.nvim_feedkeys(vim.keycode"<c-c>", "n", false)
end

local function to_path(line)
    local path = string.sub(line, #prefix + 1)
    path = tostring(Path:new(path):expand())
    return tostring(Path:new(path):absolute())
end

local function normalize(path)
    local p = path:gsub("^" .. home, "~")
    return p
end

local function create_dummy_command()
    local cmd
    local pos = prefix:find(" ")
    if pos then
        cmd = prefix:sub(1, pos - 1)
    else
        cmd = prefix
    end
    vim.api.nvim_create_user_command(cmd, function() end, {
        complete = "file",
        nargs = "*"
    })
    vim.api.nvim_create_autocmd("CmdlineLeave", {
        once = true,
        callback = function()
            vim.api.nvim_del_user_command(cmd)
        end,
    })
end

local function cmdline(arg)
    if arg == nil then
        return vim.fn.getcmdline(), vim.fn.getcmdpos()
    end

    if type(arg) == "number" then
        vim.fn.setcmdpos(arg)
    end

    if type(arg) == "string" then
        vim.fn.setcmdline(arg)
    end

    if type(arg) == "table" then
        if arg.line and arg.pos then
            vim.fn.setcmdline(arg.line, arg.pos)
        end
    end
end

local function last(str)
    return string.sub(str, -1)
end

local function set_map(lhs, rhs)
    vim.keymap.set("c", lhs, rhs)
    cached_mappings[lhs] = rhs
end

function M.actions.backspace()
    local line = to_path(cmdline())
    if Path:new(line):is_dir() then
        local path = tostring(Path:new(line):parent())
        if path == "/" then
            cmdline({ line = prefix .. path, pos = #prefix + 2 })
        else
            local parent = prefix .. path .. "/"
            cmdline({ line = parent, pos = #parent + 1 })
        end
        return
    end
    vim.api.nvim_feedkeys(vim.keycode "<bs>", "n", false)
end

function M.actions.c_w()
    local path = to_path(cmdline())
    if Path:new(path):is_dir() then
        M.actions.backspace()
        return
    end
    local last_slash = string.find(path, "/[^/]*$")
    local line = string.sub(path, 1, last_slash)
    cmdline({ line = prefix .. line, pos = #line + 1 })
end

local function start_updater(cb, start_path)
    start_path = normalize(start_path or home .. "/")
    local group = vim.api.nvim_create_augroup("find-file", { clear = false })
    vim.api.nvim_create_autocmd("CmdlineChanged", {
        once = true,
        callback = function()
            cmdline(string.format("%s%s", prefix, start_path))
            vim.api.nvim_create_autocmd("CmdlineChanged", {
                group = group,
                callback = function()
                    local l, pos = cmdline()
                    if pos <= #prefix then
                        cmdline(prefix .. "/")
                        return
                    end
                    local norm = tostring(normalize(to_path(l)))
                    local line = prefix .. norm
                    cmdline({ line = line, pos = #line + 1 })
                end,
            })
        end,
    })
    vim.api.nvim_create_autocmd("CmdlineLeave", {
        group = group,
        once = true,
        callback = function()
            vim.api.nvim_del_augroup_by_id(group)
            local line = to_path(cmdline())
            cmdline("")
            if vim.v.event.abort then
                return
            end
            vim.v.event.abort = true
            cb(line)
        end,
    })
end

local function get_cwd()
    if require("oil") and require("oil").get_current_dir() ~= nil then
        return require("oil").get_current_dir()
    end
    local path = vim.fn.expand("%:p:h") .. "/"
    if path:find("^term://") then
        path = path:match("^term://(.-)//") .. "/"
    end
    return path
end

function M.set_cmdline(str)
    vim.validate({
        str = { str, "string" }
    })
    cmdline(prefix .. str)
end

function M.get_cmdline()
    local l = cmdline()
    local norm = tostring(normalize(to_path(l)))
    return norm
end

local function set_keymaps(mappings)
    for lhs, rhs in pairs(mappings) do
        set_map(lhs, rhs)
    end
    vim.api.nvim_create_autocmd("CmdlineLeave", {
        once = true,
        callback = function()
            for lhs in pairs(cached_mappings) do
                vim.keymap.del("c", lhs)
            end
        end,
    })
end

function M.default_mappings()
    return {
        ["<bs>"] = M.actions.backspace,
        ["<c-w>"] = M.actions.c_w,
        ["<c-bs>"] = M.actions.c_w,
        ["<c-c>"] = M.actions.abort,
        ["<esc>"] = M.actions.abort,
        ["<c-f>"] = "<nop>",
        ["<c-r>%"] = function()
            local file_name = vim.fn.fnamemodify(vim.fn.getreg("%"), ":t")
            local cmd = M.get_cmdline()
            M.set_cmdline(cmd .. file_name)
        end,
        ["<c-h>"] = function()
            M.set_cmdline(home .. "/")
        end,
    }
end

function M.find_file(on_complete, mappings)
    vim.validate({
        on_complete = { on_complete, "function" },
        mappings = { mappings, "table" }
    })
    create_dummy_command()
    set_keymaps(mappings)
    local path = get_cwd()
    start_updater(vim.schedule_wrap(on_complete), path)
    vim.api.nvim_feedkeys(":e", "n", false)
end

return M
