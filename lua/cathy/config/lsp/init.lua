local icons = require("cathy.utils.icons").icons
local lsp_funcs = require("cathy.config.lsp.funcs")

vim.cmd([[sign define DiagnosticSignError text=]] .. icons.Error   .. [[ texthl=DiagnosticSignError linehl= numhl= ]])
vim.cmd([[sign define DiagnosticSignWarn text=]]  .. icons.Warning .. [[ texthl=DiagnosticSignWarn linehl= numhl= ]])
vim.cmd([[sign define DiagnosticSignInfo text=]]  .. icons.Hint    .. [[ texthl=DiagnosticSignInfo linehl= numhl= ]])
vim.cmd([[sign define DiagnosticSignHint text=]]  .. "🤓"          .. [[ texthl=DiagnosticSignHint linehl= numhl= ]])

vim.diagnostic.config({
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

vim.lsp.enable({
    "lua_ls",
    "emmet_language_server",
    "gopls",
    "jdtls",
    "rust_analyzer",
    "ts_ls",
})

vim.keymap.del("n", "gO")
