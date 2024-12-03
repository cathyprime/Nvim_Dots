vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.api.nvim_create_autocmd("BufEnter", {
    once = true,
    callback = function()
        vim.opt_local.indentexpr = 'v:lua.require("cathy.utils.indent").cpp_indent()'
    end,
})
