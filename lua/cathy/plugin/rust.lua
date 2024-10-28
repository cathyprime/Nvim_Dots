return {
    "mrcjkb/rustaceanvim",
    ft = "rust",
    init = function()
        vim.g.rustaceanvim = {
            dap = {
                disable = true
            },
            tools = {
                hover_actions = {
                    replace_builtin_hover = false
                },
                float_win_config = {
                    border = "single",
                },
            },
        }
    end
}
