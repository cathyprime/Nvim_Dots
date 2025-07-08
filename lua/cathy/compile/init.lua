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

function H.start(cmd, executable)
    local qflist = utils.QuickFix.new()

    qflist:set_title(cmd:get_plain_cmd())
    qflist:open()

    if cmd.vim_compiler then
        qflist:set_compiler(cmd.vim_compiler)
    end

    return vim.system(executable, {
        stdout = H.make_stdout_handler(cmd, qflist),
        cwd = cmd.cwd,
        detach = true,
        text = true
    })
end

---@param cmd Compile_Opts
function H.make_executable(cmd)
    local executable
    if cmd.process then
        executable = { cmd.compiler, unpack(cmd.args) }
    else
        local script = { "{", cmd.compiler, unpack(cmd.args)}
        vim.list_extend(script, { "}", "2>&1" })
        executable = {
            vim.opt.shell:get(),
            vim.opt.shellcmdflag:get(),
            table.concat(script, " ")
        }
    end
    return executable
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
    local executable = H.make_executable(cmd)
    H.start(cmd, executable)
end

return M
