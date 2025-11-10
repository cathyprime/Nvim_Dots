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
        if not last_process then
            vim.notify("No previous command!", vim.log.levels.ERROR)
            return
        end
        if last_process.is_running then
            return
        end
        last_process.e:clear()
        last_process.buf:replace_lines(0, - 1, {})
        last_process.buf._ends_with_newline = false
        last_process:start(
            vim.b[last_process.buf.bufid].executor,
            vim.b[last_process.buf.bufid].exec_opts
        )
    end,
    {
        nargs = 0
    }
)

vim.api.nvim_create_user_command(
    "Seethe",
    function ()
        if not last_process then
            vim.notify("No previous command!", vim.log.levels.ERROR)
            return
        end
        last_process:show(true)
    end,
    {}
)

vim.keymap.set("n", "<leader>q", "<cmd>Seethe<cr>", { silent = true })
vim.keymap.set("n", "'<cr>", "<cmd>Recompile<cr>", { silent = true })
vim.keymap.set("n", "'<space>", "<cmd>Compile<cr>", { silent = false })
