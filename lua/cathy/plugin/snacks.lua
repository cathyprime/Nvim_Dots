require("cathy.utils.snacks.set_ui_select")
local from_snacks = require("cathy.utils.snacks.from_snacks")

local project_opts = {
    prompt = " Projects :: ",
    dev = { "~/polygon", "~/langs", "~/Repositories/" },
    formatters = {
        file = { truncate = 10000 }
    },
    format = require("cathy.utils.snacks.format")
}

return {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        bigfile = {
            notify = true,
            size = 1.5 * 1024 * 1024,
        },
        git = {},
        zen = {
            toggles = {
                dim = false,
            }
        },
        picker = {
            ui_select = false,
            icons = {
                ui = {
                    selected = " +",
                    unselected = "  "
                }
            },
            layout = {
                preset = "ivy"
            },
            formatters = {
                file = {
                    truncate = vim.opt.columns:get(),
                },
                selected = {
                    show_always = true,
                }
            },
            layouts = {
                ivy = {
                    layout = {
                        box = "vertical",
                        backdrop = false,
                        row = -1,
                        width = 0,
                        height = 0.4,
                        border = "top",
                        title = "{live} {flags}",
                        title_pos = "left",
                        { win = "input", height = 1, border = "none" },
                        { box = "horizontal", { win = "list", border = "none" }, },
                    },
                }
            }
        },
    },
    keys = {
        { "<leader>wz", from_snacks.zen.zen() },
        { "<leader>wZ", from_snacks.zen.zoom() },

        { "<leader>fF",       from_snacks.picker.resume               {},                                                        desc = "resume"            },
        { "<leader>ff",       require("cathy.utils.snacks.find_file") { prompt = " Find File :: " },                             desc = "find file"         },
        { "<leader>fn",       from_snacks.picker.files                { prompt = " Neovim Files :: ", cwd = "~/.config/nvim/" }, desc = "config files"      },
        { "<leader>fl",       from_snacks.picker.lazy                 { prompt = " Lazy :: " },                                  desc = "lazy declarations" },
        { "<leader>fg",       from_snacks.picker.grep                 { prompt = " Grep :: " },                                  desc = "grep"              },
        { "<leader>fG",       from_snacks.picker.grep_buffers         { prompt = " Grep Buffers :: " },                          desc = "grep current file" },
        { "<leader>fh",       from_snacks.picker.help                 { prompt = " Help Tags :: " },                             desc = "help"              },
        { "<leader>fw",       from_snacks.picker.grep_word            { prompt = ">>= Grep :: " },                               desc = "cursor grep"       },
        { "<leader><leader>", from_snacks.picker.buffers              { prompt = " Buffers :: " },                               desc = "switch buffers"    },
        { "<leader>fo",       from_snacks.picker.recent               { prompt = " Oldfiles :: " },                              desc = "oldfiles"          },
        { "<leader>fp",       from_snacks.picker.projects             (project_opts),                                            desc = "project files"     },
        { "<c-p>",            from_snacks.picker.files                { prompt = " Find Files :: " },                            desc = "files"             },
        { "z=",               from_snacks.picker.spelling             { prompt = " Spelling :: ", layout = "ivy" },              desc = "spell suggestion"  },
    }
}
