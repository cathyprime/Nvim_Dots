local last_args = nil
local last_process = nil

vim.api.nvim_create_user_command(
    "Compile",
    function (e)
        last_args = vim.deepcopy(e.args)
        last_process = require("cathy.compile") {
            cmd = e.args
        }
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
        last_process = require("cathy.compile") {
            cmd = last_args
        }
    end,
    {
        nargs = 0
    }
)
vim.api.nvim_create_user_command(
    "Seethe",
    function () last_process:create_win() end,
    {}
)
vim.keymap.set("n", "'<cr>", "<cmd>Recompile<cr>", { silent = true })
vim.keymap.set("n", "'<space>", ":Compile ", { silent = false })
