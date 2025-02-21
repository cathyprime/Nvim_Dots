---@param options { forward: boolean }
local function trouble_jump(options)
    return function()
        require("demicolon.jump").repeatably_do(function(opts)
            if require("trouble").is_open() then
                if opts.forward then
                    require("trouble").next({ skip_groups = true, jump = true })
                else
                    require("trouble").prev({ skip_groups = true, jump = true })
                end
            end
        end, options)
    end
end

return {
    {
        "Eandrju/cellular-automaton.nvim",
        cmd = "CellularAutomaton"
    },
    {
        "mawkler/demicolon.nvim",
        lazy = true,
        opts = {
            keymaps = {
                horizontal_motions = true,
                diagnostic_motions = false,
                repeat_motions = false,
            },
            integrations = {
                gitsigns = {
                    enabled = false,
                },
            },
        },
        config = function(_, opts)
            require("demicolon").setup(opts)
            local ts_repeatable_move = require('nvim-treesitter.textobjects.repeatable_move')
            local nxo = {"n", "x", "o"}

            vim.keymap.set(nxo, ';', ts_repeatable_move.repeat_last_move)
            vim.keymap.set(nxo, ',', ts_repeatable_move.repeat_last_move_opposite)
        end
    },
    {
        "folke/trouble.nvim",
        config = true,
        dependencies = "mawkler/demicolon.nvim",
        cmd = "Trouble",
        opts = {
            modes = {
                current_project_diagnostics = {
                    auto_close = false,
                    mode = "diagnostics",
                    filter = {
                        any = {
                            buf = 0,
                            {
                                severity = vim.diagnostic.severity.ERROR,
                                function(item)
                                    return item.filename:find(vim.uv.cwd(), 1, true)
                                end,
                            },
                        },
                    },
                }
            }
        },
        keys = {
            { "Zx", "<cmd>Trouble lsp_document_symbols toggle focus=true<cr>", silent = true },
            { "ZX", "<cmd>Trouble current_project_diagnostics toggle<cr>", silent = true },
            { "gR", "<cmd>Trouble lsp_references toggle<cr>", silent = true },
            { "]d", trouble_jump({ forward = true}), desc = "Next trouble item" },
            { "[d", trouble_jump({ forward = false }), desc = "Prev trouble item" },
        }
    },
    "milisims/nvim-luaref",
    {
        "chrishrb/gx.nvim",
        cmd = "Browse",
        config = true,
        keys = {
            { "gX", "<cmd>Browse<cr>" }
        },
    },
    {
        "cbochs/grapple.nvim",
        config = function()
            require("grapple").setup({
                scope = "git_branch",
            })
        end,
        cmd = "Grapple",
        keys = function()
            local grapple = require("grapple")
            return {
                { "<leader>a", grapple.toggle },
                { "<leader>e", grapple.toggle_tags },
                { "<c-f>", function() grapple.select({ index = vim.v.count1 }) end },
                { "<m-a>", function() grapple.cycle_scopes("next") end },
                { "<m-x>", function() grapple.cycle_scopes("prev") end },
                { "<m-g>", function() grapple.cycle_tags("next") end },
                { "<m-t>", function() grapple.cycle_tags("prev") end }
            }
        end
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        keys = {
            { "<leader>n", "<cmd>Noice<cr>" }
        },
        opts = {
            views = {
                confirm = {
                    position = {
                        row = math.floor(vim.opt.lines:get() * .80)
                    }
                },
                cmdline_popup = {
                    position = {
                        row = math.floor(vim.opt.lines:get() * .90)
                    }
                },
            },
            presets = { bottom_search = true },
            cmdline = {
                view = "cmdline",
                format = {
                    cmdline = { conceal = false },
                    search_down = { conceal = false },
                    search_up = { conceal = false },
                    filter = { conceal = false },
                    lua = { conceal = false },
                    help = { conceal = false },
                    input = { conceal = false },
                }
            },
            lsp = {
                hover = { enabled = false },
                signature = { enabled = false },
                progress = { enabled = true },
                message = { enabled = false },
                smart_move = { enabled = false },
            },
        }
    },
}
