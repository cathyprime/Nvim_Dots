local gen = function (try, otherwise)
    return function ()
        local ok = pcall(vim.cmd, try)
        if not ok then
            pcall(vim.cmd, otherwise)
        end
    end
end

local jumps = {
    qf = {
        next = gen("cnext", "cfirst"),
        prev = gen("cprev", "clast"),
    },
    loclist = {
        next = gen("lnext", "llast"),
        prev = gen("lprev", "lfirst"),
    },
}

local function jump_quickfix(options)
    return function()
        require("demicolon.jump").repeatably_do(function(opts)
            local has_loclist = vim.fn.getloclist(0, {winid=0}).winid ~= 0
            jumps[has_loclist and "loclist" or "qf"][opts.forward and "next" or "prev"]()
        end, options)
    end
end

return {
    {
        "romainl/vim-qf",
        config = function()
            vim.g.qf_auto_quit = 0
            vim.g.qf_auto_resize = 0
            vim.g.qf_auto_open_quickfix = 0
        end
    },
    {
        "stevearc/quicker.nvim",
        event = "VeryLazy",
        dependencies = "mawkler/demicolon.nvim",
        config = function()
            require("quicker").setup({
                keys = {
                    {
                        "<c-l>",
                        require("quicker").refresh,
                        desc = "Refresh quickfix list",
                    },
                    {
                        "+",
                        function()
                            require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
                        end,
                        desc = "Expand quickfix context"
                    },
                    {
                        "-",
                        require("quicker").collapse,
                        desc = "Collapse quickfix context"
                    }
                },
            })
        end,
        keys = {
            {
                "]c",
                jump_quickfix({ forward = true }),
                desc = "Next quickfix item"
            },
            {
                "[c",
                jump_quickfix({ forward = false }),
                desc = "Prev quickfix item"
            },
            { "<leader>q", function()
                local has_loclist = vim.fn.getloclist(0, {winid=0}).winid ~= 0
                if has_loclist then
                    require("quicker").close({ loclist = true })
                    return
                end
                if vim.g.dispatch_ready then
                    vim.cmd("Copen")
                else
                    require("quicker").toggle()
                end
            end },
            {
                "<leader>Q",
                function() require("quicker").toggle({ loclist = true }) end
            }
        }
    }
}
