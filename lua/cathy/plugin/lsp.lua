return {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
        "saghen/blink.cmp",
        "williamboman/mason.nvim",
        "neovim/nvim-lspconfig",
    },
    config = function()
        require("cathy.config.lsp")
    end,
    event = "VeryLazy",
}
