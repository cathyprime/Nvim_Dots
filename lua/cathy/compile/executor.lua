local M = {}

function M.shell(opts)
    vim.validate("opts.cmd", opts.cmd, "string")
    vim.validate("opts.cwd", opts.cwd, "string")
    vim.validate("opts.write_cb", opts.write_cb, "function")
    vim.validate("opts.exit_cb", opts.exit_cb, "function")

    local command = {
        vim.opt.shell:get(),
        vim.opt.shellcmdflag:get(),
        opts.cmd .. " 2>&1",
    }

    return vim.system(command, {
        stdout = opts.write_cb,
        cwd = opts.cwd,
        detach = false,
        text = true,
    }, opts.exit_cb)
end

return M
