local utils = lazy_require("cathy.compile.utils")

local M = {}
local H = {}

function H.prepare_data(data)
    if type(data) == "string" then
        data = vim.split(data, "\n", { plain = true, trimempty = true })
    end
    assert(type(data) == "table")
    return data
end

---@param cmd Compile_Opts
function H.make_stdout_handler(cmd, qflist)
    local setqflist = vim.schedule_wrap(function (data)
        data = H.prepare_data(data)
        qflist:append_lines(data)
    end)
    return function (_, data)
        if data then
            setqflist(data)
        end
    end
end

function M.quickfixtextfunc(info)
    local items = vim.fn.getqflist({ id = info.id, items = 1 }).items
    local l = {}

    for idx = info.start_idx - 1, info.end_idx - 1 do
        local item = items[idx + 1]

        local filename = ""
        if item.bufnr and item.bufnr > 0 then
            filename = vim.fn.bufname(item.bufnr)
        end

        if (item.text or ""):match("^%s*$") and (filename == "" or not item.lnum or item.lnum == 0) then
            table.insert(l, " ")
        else
            local parts = {}

            if filename ~= "" then
                table.insert(parts, filename)
            end
            if item.lnum and item.lnum > 0 then
                table.insert(parts, tostring(item.lnum))
            end
            if item.col and item.col > 0 then
                table.insert(parts, tostring(item.col))
            end

            local line
            if #parts > 0 then
                line = table.concat(parts, ":") .. ":" .. (item.text or "")
            else
                line = item.text or ""
            end

            table.insert(l, line)
        end
    end

    return l
end

function H.set_opts(qflist)
    qflist:buf_call(function ()
        vim.b.minitrailspace_disable = true
        vim.b.compile_mode = true
        vim.opt_local.modifiable = false
    end)
    qflist:cleanup_buf_call(function ()
        vim.b.minitrailspace_disable = nil
        vim.b.compile_mode = nil
        vim.opt_local.modifiable = true
    end)
    qflist:win_call(function ()
        vim.wo.list = false
        vim.wo.winfixbuf = true
    end)
    qflist:cleanup_win_call(function ()
        vim.wo.list = true
        vim.wo.winfixbuf = false
    end)
end

function H.start(cmd, executable)
    local qflist = utils.QuickFix.new()

    qflist:open()
    qflist:set_title(cmd:get_plain_cmd())
    qflist:set_text_func("v:lua.require'cathy.compile'.quickfixtextfunc")
    qflist:append_lines({
        plain = true,
        string.format("-*- Compilation_Mode; Starting_Directory :: \"%s\" -*-", cmd.cwd),
        string.format("Compilation started at %s", os.date "%a %b %d %H:%M:%S"),
        "",
        cmd:get_plain_cmd()
    })
    qflist:set_compiler(cmd.vim_compiler)
    H.set_opts(qflist)

    local start_time = vim.uv.hrtime()
    local on_exit = vim.schedule_wrap(function (proc)
        local duration = (vim.uv.hrtime() - start_time) / 1e9
        local code_func = require("cathy.compile.signalis").signals[proc.code]

        local msg, color_func = code_func(duration, 69)
        qflist:append_lines({
            plain = true,
            "",
            msg
        })
        qflist:apply_color(color_func)
    end)

    return vim.system(executable, {
        stdout = H.make_stdout_handler(cmd, qflist),
        cwd = cmd.cwd,
        detach = true,
        text = true
    }, on_exit)
end

function H.open_term(cmd)
    vim.api.nvim_open_win(0, true, {
        vertical = true,
        split = "below"
    })
    vim.cmd.lcd(cmd.cwd)
    vim.cmd("noau term " .. cmd:get_plain_cmd())

    vim.keymap.set("n", "q", function ()
        vim.api.nvim_win_close(0, false)
    end, { buffer = env.buf, silent = true, noremap = true, nowait = true })

    vim.api.nvim_create_autocmd("BufHidden", {
        once = true,
        buffer = vim.api.nvim_get_current_buf(),
        callback = function (ev)
            local pid = vim.b[ev.buf].terminal_job_id
            if pid then
                vim.fn.jobstop(pid)
            end
            vim.defer_fn(function()
                pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
            end, 100)
        end
    })
end

---@param cmd Compile_Opts
function M.exec(cmd)
    cmd = utils.Compile_Opts.new(cmd)
    if cmd.interactive then
        H.open_term(cmd)
        return
    end
    local executable = cmd:make_executable()
    H.start(cmd, executable)
end

return M
