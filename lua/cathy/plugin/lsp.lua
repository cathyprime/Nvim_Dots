return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "saghen/blink.cmp",
    },
    config = function()
        require("cathy.config.lsp")
    end,
    event = "VeryLazy",
}
