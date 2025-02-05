require("cathy.utils.snacks.set_ui_select")
local from_snacks = require("cathy.utils.snacks.from_snacks")

local f = require("cathy.utils.snacks.format")

local cb_maker = function (picker_type, opts)
    return function (picker, item)
        picker:close()
        opts = vim.tbl_deep_extend("force", opts or {}, { cwd = item.file })
        Snacks.picker[picker_type](opts)
    end
end

local buffer_opts = {
    prompt = " Buffers :: ",
    format = f,
    nofile = true,
    hidden = true,
    -- filter = {
    --     filter = function (arg1, arg2)
    --         print("arg1:")
    --         put(arg1)
    --         print("arg2:")
    --         put(arg2)
    --         return true
    --     end
    -- }
}

local project_opts = {
    prompt = " Projects :: ",
    dev = { "~/polygon", "~/langs", "~/Repositories/" },
    format = f,
    actions = {
        ["picker_files"] = cb_maker("files", { prompt = " Find Files :: " }),
        ["picker_grep"] = cb_maker("grep", { prompt = " Grep :: " }),
        ["picker_recent"] = cb_maker("recent", { prompt = " Oldfiles :: ", format = f }),
    },
    confirm = cb_maker("files", { prompt = " Find Files :: " }),
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
            },
            win = {
                backdrop = {
                    transparent = false
                }
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
            format = f,
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
        { "<leader>fo",       from_snacks.picker.recent               { prompt = " Oldfiles :: ", format = f },                  desc = "oldfiles"          },
        { "<leader><leader>", from_snacks.picker.buffers              (buffer_opts),                                             desc = "switch buffers"    },
        { "<leader>fp",       from_snacks.picker.projects             (project_opts),                                            desc = "project files"     },
        { "<c-p>",            from_snacks.picker.files                { prompt = " Find Files :: " },                            desc = "files"             },
        { "z=",               from_snacks.picker.spelling             { prompt = " Spelling :: ", layout = "ivy" },              desc = "spell suggestion"  },
    }
}
