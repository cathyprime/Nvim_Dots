vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4

vim.api.nvim_create_autocmd("BufEnter", {
    once = true,
    callback = function()
        vim.opt.indentkeys:remove("<>>")
        vim.opt.indentkeys:remove("=case")
    end
})
