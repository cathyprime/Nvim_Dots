local running_process = nil

return function (opts)
    vim.validate("opts",          opts,          "table")
    vim.validate("opts.cmd",      opts.cmd,      "string")
    vim.validate("opts.cwd",      opts.cwd,      "string",   true)
    vim.validate("opts.executor", opts.executor, "string",   true)
    vim.validate("opts.write_cb", opts.write_cb, "function", true)
    vim.validate("opts.exit_cb",  opts.exit_cb,  "function", true)
    opts.executor = opts.executor or "shell"

    if running_process then
        return running_process
    end

    local process = require("cathy.compile.process")
    running_process = process.new()
    running_process.on_exit = function ()
        running_process = nil
    end
    running_process:start(opts.executor, opts)
    return running_process
end
