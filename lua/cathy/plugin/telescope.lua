local telescope_utils = require("cathy.utils.telescope")

return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    lazy = true,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "stevearc/dressing.nvim",
        "stevearc/oil.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build =
            "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
        },
    },
    config = function(_, opts)
        require("telescope").setup(opts)
        require("telescope").load_extension("fzf")
        require("telescope").load_extension("projects")
    end,
    opts = function()
        local telescope_config = require("cathy.utils.telescope.config")
        local actions = require("telescope.actions")

        local defaults = {
            borderchars = telescope_config.borderchars,
            border = telescope_config.border,
            layout_config = telescope_config.layout_config,
            mappings = {
                i = {
                    ["<C-q>"] = function(...)
                        return actions.smart_send_to_qflist(...)
                    end,
                },
            },
        }
        return {
            defaults = vim.tbl_deep_extend("force", require("telescope.themes").get_ivy(), defaults),
            pickers = {
                buffers = {
                    mappings = {
                        i = {
                            ["<m-d>"] = "delete_buffer",
                        }
                    }
                }
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
                projects = {
                    mappings = {
                        i = {
                            ["<c-f>"] = telescope_utils.find_files
                        },
                        n = {
                            ["f"] = telescope_utils.find_files
                        },
                    }
                },
            }
        }
    end,
    keys = {
        { "<leader>fw",       telescope_utils.get_word,           desc = "cursor grep"       },
        { "<c-p>",            telescope_utils.find_files,         desc = "files"             },
        { "<leader><leader>", telescope_utils.project_files,      desc = "project files"     },
        { "<leader>fn",       telescope_utils.get_nvim,           desc = "config files"      },
        { "<leader>fG",       telescope_utils.grep_current_file,  desc = "grep current file" },
        { "<leader>b",        telescope_utils.buffers,            desc = "switch buffers"    },
        { "<leader>fg",       telescope_utils.multi_grep,         desc = "grep"              },
        { "<leader>ff",       telescope_utils.find_file,          desc = "files"             },
        { "<leader>fF",       telescope_utils.resume,             desc = "resume"            },
        { "<leader>fs",       telescope_utils.treesitter,         desc = "treesitter"        },
        { "<leader>fd",       telescope_utils.diagnostics,        desc = "diagnostics"       },
        { "<leader>fo",       telescope_utils.oldfiles,           desc = "oldfiles"          },
        { "<leader>fh",       telescope_utils.help_tags,          desc = "help"              },
        { "<leader>fp",       telescope_utils.project,            desc = "project files"     },
        { "z=",               telescope_utils.spell_suggest,      desc = "spell suggestion"  },
    }
}
