vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(ev)
        local value = ev.data.params.value
        vim.api.nvim_echo({ { value.message or "done" } }, false, {
            id = "lsp." .. ev.data.client_id,
            kind = "progress",
            source = "vim.lsp",
            title = value.title,
            status = value.kind ~= "end" and "running" or "success",
            percent = value.percentage,
        })
    end,
})

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

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local funcs = require("cathy.config.lsp.funcs")
        funcs.on_attach(
            vim.lsp.get_client_by_id(ev.data.client_id),
            ev.buf,
            vim.b["alt_lsp_maps"]
        )
    end,
})

vim.keymap.del("n", "gO")
