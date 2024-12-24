return {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
        "saghen/blink.cmp",
        "williamboman/mason.nvim",
        "neovim/nvim-lspconfig",
        {
            "ray-x/lsp_signature.nvim",
            lazy = true,
            opts = {
                hint_enable = false,
                floating_window = false,
                toggle_key_flip_floatwin_setting = true,
                bind = true,
                hint_prefix = "",
                always_trigger = false,
                toggle_key = "<c-h>",
            },
        },
    },
    config = function()
        require("cathy.config.lsp")
    end,
    event = "VeryLazy",
}
