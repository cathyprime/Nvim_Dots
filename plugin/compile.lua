local last_args = nil
vim.api.nvim_create_user_command(
    "Compile",
    function (e)
        last_args = vim.deepcopy(e.args)
        require("cathy.compile")({
            cmd = e.args
        })
    end,
    {
        nargs = "+",
    }
)
vim.api.nvim_create_user_command(
    "Recompile",
    function ()
        if not last_args then
            vim.notify("No previous command!", vim.log.levels.ERROR)
            return
        end
        require("cathy.compile")({
            cmd = last_args
        })
    end,
    {
        nargs = 0
    }
)
vim.keymap.set("n", "'<cr>", "<cmd>Recompile<cr>", { silent = true })
vim.keymap.set("n", "'<space>", ":Compile ", { silent = false })
