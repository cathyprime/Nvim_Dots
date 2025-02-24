vim.g.dispatch_handlers = {
    "terminal",
    "headless",
    "job",
}

local function oil_args(args)
    local dir = require("oil").get_current_dir(vim.api.nvim_get_current_buf())
    if not dir then
        return args
    end
    return string.format("-dir=%s %s", dir, args)
end

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        vim.api.nvim_del_user_command("Dispatch")
        vim.api.nvim_create_user_command(
            "Dispatch",
            function(opts)
                local count = 0
                local args = oil_args(opts.args or "")
                local mods = opts.mods or ""
                local bang = opts.bang and 1 or 0

                if bang == 1 then
                    vim.g["dispatch_ready"] = true
                end
                if opts.count < 0 or opts.line1 == opts.line2 then
                    count = opts.count
                end
                if args == "" and vim.b.dispatch ~= "" then
                    args = vim.b.dispatch
                end
                vim.b["dispatch"] = args
                vim.fn["dispatch#compile_command"](bang, args, count, mods)
            end,
            {
                bang = true,
                nargs = "*",
                range = -1,
                complete = "customlist,dispatch#command_complete",
            }
        )
        vim.api.nvim_del_user_command("Start")
        vim.api.nvim_create_user_command(
            "Start",
            function(opts)
                local count = 0
                local args = oil_args(opts.args or "")
                local mods = opts.mods or ""
                local bang = opts.bang and 0 or 1

                if opts.count < 0 or opts.line1 == opts.line2 then
                    count = opts.count
                end
                if args == "" and vim.b.start ~= "" then
                    args = vim.b.start or ""
                end
                vim.b["start"] = args
                vim.api.nvim_create_autocmd("BufAdd", {
                    callback = function(env)
                        vim.keymap.set("n", "q", function()
                            vim.api.nvim_win_close(0, false)
                        end, { buffer = env.buf, silent = true, noremap = true, nowait = true })

                        vim.api.nvim_create_autocmd("BufHidden", {
                            buffer = env.buf,
                            callback = function ()
                                local pid = vim.b[env.buf].terminal_job_id
                                if pid then
                                    vim.fn.jobstop(pid)
                                end
                                vim.defer_fn(function()
                                    pcall(vim.api.nvim_buf_delete, env.buf, { force = true })
                                end, 100)
                            end
                        })
                    end,
                })
                if args:find "sudo" then
                    vim.fn["dispatch#start_command"](0, "-wait=always " .. args, count, mods)
                else
                    vim.fn["dispatch#start_command"](bang, "-wait=always " .. args, count, mods)
                end
            end,
            {
                bang = true,
                nargs = "*",
                range = -1,
                complete = "customlist,dispatch#command_complete",
            }
        )
        vim.api.nvim_del_user_command("Make")
        vim.api.nvim_create_user_command(
            "Make",
            function(opts)
                local count = 0
                local args = opts.args
                local mods = opts.mods or ""
                local bang = opts.bang and 1 or 0

                if opts.count < 0 or opts.line1 == opts.line2 then
                    count = opts.count
                end
                if args == "" and vim.b.make ~= "" then
                    args = vim.b.make or ""
                end
                vim.b["make"] = args
                vim.fn["dispatch#compile_command"](bang, "-- " .. args, count, mods)
            end,
            {
                bang = true,
                nargs = "*",
                range = -1,
                complete = "customlist,dispatch#command_complete",
            }
        )
        vim.api.nvim_del_user_command("Copen")
        vim.api.nvim_create_user_command(
            "Copen",
            function(opts)
                local bang = opts.bang and 1 or 0
                vim.g["dispatch_ready"] = false
                vim.fn["dispatch#copen"](bang, opts.mods or "")
            end,
            {
                bang = true,
                bar = true,
            }
        )
    end,
})

return {
    {
        "tpope/vim-dispatch",
        config = function()
            vim.keymap.set("n", "Zc", "<cmd>AbortDispatch<cr>", { silent = true  })
            vim.keymap.set("n", "ZC", "<cmd>AbortDispatch<cr>", { silent = true  })
        end,
    },
}
