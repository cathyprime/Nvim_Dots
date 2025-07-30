local utils = lazy_require("cathy.compile.utils")

local M = {}
local H = {}

function H.prepare_data(data)
    if type(data) == "string" then
        data = vim.split(data, "[\n\r]+", { plain = false, trimempty = true })
    elseif type(data) == "table" then
        data = vim.iter(data)
            :map(function (value)
                return (value:gsub("\r$", ""))
            end)
            :filter(function (value)
                return value ~= ""
            end)
            :totable()
    end
    return data
end

---@param cmd Compile_Opts
function H.make_stdout_handler(cmd, qflist)
    local setqflist = vim.schedule_wrap(function (data)
        data = H.prepare_data(data)
        local ansi = require("cathy.ansi")
        if ansi.has_ansi_code(data) then
            local stripped_data, color_func = ansi.strip_lines(data)
            local linenr = qflist:get().size
            qflist:append_lines(stripped_data)
            qflist:apply_color(color_func, linenr)
        else
            qflist:append_lines(data)
        end
    end)
    return function (_, data)
        if data and #data > 0 then
            setqflist(data)
        end
    end
end

function H.start(cmd)
    local qflist = utils.QuickFix.new()

    qflist:open()
    qflist:set_title(cmd:get_plain_cmd())
    local cwd = cmd.cwd
    if string.sub(cwd, -1) ~= "/" then
        cwd = cmd.cwd .. "/"
    end
    if cwd:find(os.getenv "HOME") then
        cwd = (cwd:gsub(os.getenv "HOME", "~"))
    end
    if M.running_job then
        local pid = vim.fn.jobpid(M.running_job)
        if pid then
            vim.uv.kill(-pid, "sigint")
            M.running_job:wait()
            M.last_job_killed = true
            M.running_job = nil
            qflist:clear()
        end
    end
    qflist:append_lines({
        plain = true,
        string.format("-*- Compilation_Mode; Starting_Directory :: \"%s\" -*-", cwd),
        string.format("Compilation started at %s", os.date "%a %b %d %H:%M:%S"),
        "",
        cmd:get_plain_cmd()
    })
    qflist:set_compiler(cmd.vim_compiler)

    local start_time = vim.uv.hrtime()
    local on_exit = vim.schedule_wrap(function (_, exit_code)
        if M.last_job_killed then
            M.last_job_killed = nil
            return
        end
        local duration = (vim.uv.hrtime() - start_time) / 1e9
        local code_func = require("cathy.compile.signalis")[exit_code]

        local msg, color_func = code_func(duration)
        qflist:append_lines({
            plain = true,
            "",
            msg
        })
        qflist:apply_color(color_func)
        M.running_job = nil
    end)

    M.running_job = vim.fn.jobstart(cmd:make_executable(), {
        on_stdout = H.make_stdout_handler(cmd, qflist),
        pty = true,
        cwd = cmd.cwd,
        -- text = false,
        on_exit = on_exit,
        env = {
            TERM = "xterm 256color"
        }
    })
end

function H.open_term(cmd)
    vim.api.nvim_open_win(0, true, {
        vertical = true,
        split = "below"
    })
    vim.cmd.lcd(cmd.cwd)
    vim.cmd("noau term " .. cmd:get_plain_cmd())
    local winnr = vim.api.nvim_get_current_win()
    vim.wo[winnr].scrolloff = 0
    vim.wo[winnr].spell = false
    vim.b.minitrailspace_disable = true

    vim.keymap.set("n", "q", function ()
        vim.api.nvim_win_close(0, false)
    end, { buffer = true, silent = true, noremap = true, nowait = true })

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
    H.start(cmd)
end

return M
