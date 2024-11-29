local icons = require("cathy.utils.icons").icons
local lsp_funcs = require("cathy.config.lsp.funcs")
require("cathy.config.lsp.progress_handler")
-- require("cathy.config.lsp.echodoc")
vim.lsp.handlers.hover = require("cathy.config.lsp.hover").hover

vim.cmd([[sign define DiagnosticSignError text=]] .. icons.Error   .. [[ texthl=DiagnosticSignError linehl= numhl= ]])
vim.cmd([[sign define DiagnosticSignWarn text=]]  .. icons.Warning .. [[ texthl=DiagnosticSignWarn linehl= numhl= ]])
vim.cmd([[sign define DiagnosticSignInfo text=]]  .. icons.Hint    .. [[ texthl=DiagnosticSignInfo linehl= numhl= ]])
vim.cmd([[sign define DiagnosticSignHint text=]]  .. "🤓"          .. [[ texthl=DiagnosticSignHint linehl= numhl= ]])

vim.diagnostic.config({
    -- virtual_text = {
    --     prefix = "⚫︎"
    -- },
    virtual_text = false,
    signs = false,
    underline = false,
    float = {
        border = "rounded"
    }
})
-- vim.diagnostic.enable(false)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
})

local function disabled()
    return true
end

vim.lsp.log.set_level(vim.log.levels.ERROR)

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "emmet_ls",
        "gopls",
        "jdtls",
        "lua_ls",
        "rust_analyzer",
        "ts_ls",
    },
    handlers = {
        lsp_funcs.default_setup,
        jdtls = disabled,
        rust_analyzer = disabled,
        lua_ls = lsp_funcs.lua_ls,
    }
})
