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
        "folke/noice.nvim",
        lazy = false,
        keys = {
            { "<leader>n", "<cmd>Noice<cr>" }
        },
        opts = {
            routes = {
                {
                    filter = {
                        event = "msg_show",
                        cmdline = ":grep"
                    },
                    opts = { skip = true }
                }
            },
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
            presets = {
                bottom_search = true,
                lsp_doc_border = true,
                long_message_to_split = true,
            },
            cmdline = {
                view = "cmdline",
                format = {
                    search_down = { conceal = false },
                    search_up = { conceal = false },
                    cmdline = { conceal = false },
                    filter = { conceal = false },
                    input = { conceal = false },
                    help = { conceal = false },
                    lua = { conceal = false },
                }
            },
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                },
                signature = { enabled = false },
                progress = { enabled = true },
                message = { enabled = true },
                hover = { enabled = true },
            },
        }
    },
}
