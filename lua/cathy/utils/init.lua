local M = {}

local function term(mods, command, opts)
    vim.cmd(string.format("exec 'noa %s term %s' | startinsert", mods, command))
    if opts.title then
        vim.api.nvim_buf_set_name(0, opts.title)
    end
    local winnr = vim.api.nvim_get_current_win()
    vim.wo[winnr].relativenumber = false
    vim.wo[winnr].signcolumn = "no"
    vim.wo[winnr].scrolloff = 0
    vim.wo[winnr].number = false
    vim.wo[winnr].spell = false
    if opts.close then
        vim.api.nvim_create_autocmd("TermClose", {
            once = true,
            buffer = vim.api.nvim_get_current_buf(),
            command = "bd!",
        })
    end
end

function M.tab_term(command, opts)
    if type(command) == "table" then
        command = table.concat(command, " ")
    end
    if type(command) ~= "string" then
        error "command should be string/table"
    end
    term("tab", command, opts)
end

function M.clear_maps(bufnr, mode)
    local maps = vim.api.nvim_get_keymap(mode)
    for _, map in ipairs(maps) do
        vim.keymap.set(mode, map.lhs, "<nop>", { buffer = bufnr })
    end
end

function M.map_gen(default_opts)
    return function(modes, lhs, rhs, opts)
        opts = opts or {}
        local options = vim.tbl_deep_extend("keep", opts, default_opts)
        vim.keymap.set(modes, lhs, rhs, options)
    end
end

function M.cur_buffer_path()
    local oil = require("oil").get_current_dir()
    if oil then
        return oil
    else
        local expand = vim.fn.expand("%:p:h")
        if expand:match "^term" then
            expand = vim.fn.fnamemodify(expand:gsub("term://", ""):gsub("//.*", ""), ":p")
        end
        return expand .. "/"
    end
end

local function validate_sudo_timeout()
    local out = vim.system({ "sudo", "-n", "true" }, {}):wait()
    return out.code == 0
end

local function not_interactive_sudo(cmd)
    local out = vim.system({ "sudo", "-n", "sh", "-c", cmd }, {}):wait()
    if out.code ~= 0 then
        vim.notify(out.stderr, vim.log.levels.ERROR)
        return false
    end
    return true
end

function M.sudo_exec(cmd)
    if validate_sudo_timeout() then
        return not_interactive_sudo(cmd)
    end
    vim.fn.inputsave()
    local password = vim.fn.inputsecret("Password: ")
    vim.fn.inputrestore()
    if not password or #password == 0 then
        vim.notify("Invalid password, sudo aborted", vim.log.levels.WARN)

        return false
    end

    local out = vim.system({ "sudo", "-S", "sh", "-c", cmd }, { stdin = password .. '\n' }):wait()
    collectgarbage("collect")

    if out.code ~= 0 then
        vim.notify(out.stderr, vim.log.levels.ERROR)
        return false
    end
    return true
end

function M.sudo_write()
    local tmpfile = vim.fn.tempname()
    local filepath = vim.fn.expand("%")
    if not filepath or #filepath == 0 then
        vim.notify("E32: No file name", vim.log.levels.ERROR)
        return
    end
    local cmd = string.format("dd if=%s of=%s bs=1048576",
        vim.fn.shellescape(tmpfile),
        vim.fn.shellescape(filepath))
    vim.api.nvim_exec2(string.format("write! %s", tmpfile), { output = true })
    if sudo_exec(cmd) then
        -- refreshes the buffer and prints the "written" message
        vim.cmd.checktime()
        vim.api.nvim_feedkeys(vim.keycode "<Esc>", "n", true)
    end
    vim.fn.delete(tmpfile)
    return true
end

local check_values = setmetatable({
    mode  = false,
    lhs   = false,
    rhs   = false,
    setup = false
}, { __index = function () return true end })

function M.lazy_keymap(tbl)
    local map_opts = {}
    for k, v in pairs(map_opts) do
        if check_values[v] then
            map_opts[k] = v
        end
    end

    local setup_f = function ()
        vim.keymap.del(tbl.mode, tbl.lhs, map_opts)
        tbl.setup()
        vim.keymap.set(tbl.mode, tbl.lhs, tbl.rhs, map_opts)
        vim.api.nvim_feedkeys(vim.keycode(tbl.lhs), "m", false)
    end

    vim.keymap.set(tbl.mode, tbl.lhs, setup_f, map_opts)
end

return M
