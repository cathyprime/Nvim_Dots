require("cathy.compile2.highlights")

return function (opts)
    vim.validate("opts.executor", opts.executor, "string")
    vim.validate("opts.cmd", opts.cmd, "string")

    vim.print(opts)
end
