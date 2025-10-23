local M = {}

function M.shell(opts)
    vim.validate("cmd", opts.cmd, "string")
    vim.validate("cwd", opts.cwd, "string")
    vim.validate("write_cb", opts.write_cb, "function")
    vim.validate("exit_cb", opts.exit_cb, "function")

    return vim.fn.jobstart(opts.cmd, {
        env = { TERM = "xterm-256color" },
        on_stdout = opts.write_cb,
        on_exit = opts.exit_cb,
        cwd = opts.cwd,
        detach = false,
        pty = true,
    })
end

return M
