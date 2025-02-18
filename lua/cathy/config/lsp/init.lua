local icons = require("cathy.utils.icons").icons
local lsp_funcs = require("cathy.config.lsp.funcs")
require("cathy.config.lsp.progress_handler")
-- require("cathy.config.lsp.echodoc")

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
        lua_ls = lsp_funcs.lua_ls,
    }
})
