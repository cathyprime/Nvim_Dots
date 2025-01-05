vim.opt_local.expandtab = true
vim.g.termdebugger = "rust-gdb"

vim.b.dispatch = "cargo build"
vim.b.start = "cargo run"
vim.api.nvim_create_autocmd("BufEnter", {
    once = true,
    callback = function()
        local path = vim.fn.split(vim.fn.getcwd(), "/")
        vim.b.project_name = path[#path]
        vim.b.termdebug_command = string.format("Termdebug target/debug/%s", vim.b.project_name)
    end,
})
