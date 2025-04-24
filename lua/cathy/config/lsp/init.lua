vim.diagnostic.config({
    virtual_text = false,
    signs = false,
    underline = false,
    float = {
        border = "rounded"
    }
})

vim.lsp.log.set_level(vim.log.levels.ERROR)

vim.lsp.enable({
    "lua_ls",
    "emmet_language_server",
    "gopls",
    "jdtls",
    "rust_analyzer",
    "ts_ls",
})

vim.keymap.del("n", "gO")
