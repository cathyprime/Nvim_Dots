local last_args = nil
local last_process = nil

vim.api.nvim_create_user_command(
    "Compile",
    function (e)
        local on_confirm = function (input)
            if not input then return end
            last_args = input
            last_process = require("cathy.compile") {
                cmd = vim.fn.expandcmd(input)
            }
        end
        vim.ui.input(
            {
                prompt = "Compile Command :: ",
                default = last_args,
                completion = "shellcmdline"
            },
            on_confirm
        )
    end,
    {
        nargs = 0
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
            cmd = vim.fn.expandcmd(last_args)
        }
    end,
    {
        nargs = 0
    }
)

vim.api.nvim_create_user_command(
    "Seethe",
    function () last_process:show() end,
    {}
)

vim.keymap.set("n", "'<cr>", "<cmd>Recompile<cr>", { silent = true })
vim.keymap.set("n", "'<space>", "<cmd>Compile<cr>", { silent = false })
