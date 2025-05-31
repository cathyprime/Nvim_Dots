return {
    {
        "stevearc/quicker.nvim",
        event = "VeryLazy",
        dependencies = "nvim-treesitter/nvim-treesitter-textobjects",
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
        keys = function ()
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

            local jump = function (forward)
                local has_loclist = vim.fn.getloclist(0, {winid=0}).winid ~= 0
                local list_type = has_loclist and "loclist" or "qf"
                local direction = forward and "next" or "prev"
                jumps[list_type][direction]()
            end

            local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
            local jump_next, jump_prev = ts_repeat_move.make_repeatable_move_pair(
                function () jump(true) end,
                function () jump(false) end
            )

            return {
                {
                    "]c", jump_next, desc = "Next quickfix item"
                },
                {
                    "[c", jump_prev, desc = "Prev quickfix item"
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
        end
    }
}
