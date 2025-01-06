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
                    mode = "diagnostics", -- inherit from diagnostics mode
                    filter = {
                        any = {
                            buf = 0, -- current buffer
                            {
                                severity = vim.diagnostic.severity.ERROR, -- errors only
                                -- limit to files in the current project
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
    {
        "mbbill/undotree",
        config = function()
            vim.g.undotree_WindowLayout = 2
            vim.g.undotree_ShortIndicators = 0
            vim.g.undotree_SplitWidth = 40
            vim.g.undotree_SetFocusWhenToggle = 1
            vim.g.undotree_DiffCommand = [[diff]]
        end,
        keys = {
            { "<leader>u", "<cmd>UndotreeToggle<cr>" }
        }
    },
    "milisims/nvim-luaref",
    {
        "folke/zen-mode.nvim",
        cmd = "ZenMode",
        keys = { { "<leader>w", "<cmd>ZenMode<cr>" } },
        config = function()
            require("zen-mode").setup({
                plugins = {
                    options = {
                        enabled = true,
                        ruler = false,
                        showcmd = false,
                        laststatus = 0,
                    },
                    twilight = { enabled = false },
                    gitsigns = { enabled = true },
                    wezterm = {
                        enabled = true,
                        font = 4,
                    },
                    neovide = {
                        enabled = true,
                        scale = 1.02
                    },
                },
                on_open = function()
                    vim.opt.fillchars = [[foldclose:>,foldopen:v,foldsep: ,fold: ]]
                end
            })
        end
    },
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
                { "<m-h>", function() grapple.cycle_tags("next") end },
                { "<m-g>", function() grapple.cycle_tags("prev") end }
            }
        end
    },
    {
        "cathyprime/project.nvim",
        config = function()
            require("project_nvim").setup({
                show_hidden = true,
                detection_methods = { "pattern" },
                exclude_dirs = {
                    ".",
                    "~/.cargo/*",
                    "~/.rustup/*",
                    "~/.local/*",
                    "~/go/pkg/*",
                    "*neovide-derive*",
                    "/usr/*",
                    "*src*",
                    "*node_modules/*",
                },
                patterns = {
                    ".git",
                    "_darcs",
                    ".hg",
                    ".bzr",
                    ".svn",
                    "*.csproj",
                    "Makefile",
                    "README.md",
                    "package.json",
                    "build.sbt",
                    "main.c",
                    "main.cc",
                    "main.cpp",
                    "gradlew",
                    "go.mod",
                    "Cargo.toml",
                    "docker-compose.yml",
                    "index.html",
                },
                file_ignore_patterns = require("cathy.utils.telescope.config").ignores,
            })
        end
    },
    { -- to be deleted, as I only need R for some time
        "R-nvim/R.nvim",
        lazy = false,
        version = "~0.1.0",
        config = function()
            -- Create a table with the options to be passed to setup()
            local opts = {
                hook = {
                    on_filetype = function()
                        vim.api.nvim_buf_set_keymap(0, "n", "<cr>", "<Plug>RDSendLine", {})
                        vim.api.nvim_buf_set_keymap(0, "v", "<cr>", "<Plug>RSendSelection", {})
                    end
                },
                R_args = {"--quiet", "--no-save"},
                min_editor_width = 72,
                rconsole_width = 78,
                objbr_mappings = { -- Object browser keymap
                    c = 'class', -- Call R functions
                    ['<localleader>gg'] = 'head({object}, n = 15)', -- Use {object} notation to write arbitrary R code.
                    v = function()
                        -- Run lua functions
                        require('r.browser').toggle_view()
                    end
                },
                disable_cmds = {
                    "RClearConsole",
                    "RCustomStart",
                    "RSaveClose",
                },
            }
            require("r").setup(opts)
        end,
    },
}
