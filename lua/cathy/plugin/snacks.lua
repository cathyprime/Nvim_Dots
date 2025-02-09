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

local with_layout = function (p)
    return function (opts)
        return vim.tbl_deep_extend("force", { layout = p }, opts or {})
    end
end

local nopreview = with_layout { preview = false }
local mainprevw = with_layout { preview = "main" }

local picker_mappings = {
    undo         = "<leader>u",
    find_file    = "<leader>ff",
    resume       = "<leader>fF",
    nvim_files   = "<leader>fn",
    lazy         = "<leader>fl",
    grep         = "<leader>fg",
    grep_buffers = "<leader>fG",
    help         = "<leader>fh",
    grep_word    = "<leader>fw",
    recent       = "<leader>fo",
    buffers      = "<leader><leader>",
    files        = "<c-p>",
    spelling     = "z=",
    projects     = "<leader>fp"
}

local picker_opts = {
    find_file    = { prompt = " Find file :: ", desc = "find file" },
    resume       = { desc = "resume" },
    undo         = mainprevw { prompt = " Undo :: ",         desc = "undo" },
    nvim_files   = nopreview { prompt = " Neovim Files :: ", desc = "config files", cwd = "~/.config/nvim/" },
    lazy         = nopreview { prompt = " Lazy :: ",         desc = "lazy declarations" },
    grep         = nopreview { prompt = " Grep :: ",         desc = "grep" },
    grep_buffers = nopreview { prompt = " Grep Buffers :: ", desc = "grep current file" },
    help         = nopreview { prompt = " Help Tags :: ",    desc = "help" },
    grep_word    = nopreview { prompt = ">>= Grep :: ",      desc = "cursor grep" },
    recent       = nopreview { prompt = " Oldfiles :: ",     desc = "oldfiles", format = f },
    buffers      = nopreview { prompt = " Buffers :: ",      desc = "switch buffers", format = f, nofile = true },
    files        = nopreview { prompt = " Files :: ",        desc = "files" },
    spelling     = nopreview { prompt = " Spelling :: ",     desc = "spell suggestion", layout = "ivy" },
    projects     = nopreview {
        prompt   = " Projects :: ",
        dev      = { "~/polygon", "~/langs", "~/Repositories/" },
        format   = f,
        desc     = "projects",
        actions  = {
            ["picker_grep"]   = cb_maker("grep",   { prompt = " Grep :: " }),
            ["picker_files"]  = cb_maker("files",  { prompt = " Find Files :: " }),
            ["picker_recent"] = cb_maker("recent", { prompt = " Oldfiles :: ", format = f }),
        },
        confirm = cb_maker("files", { prompt = " Find Files :: " }),
    },
}

local picks = setmetatable({
    find_file = require("cathy.utils.snacks.find_file"),
    nvim_files = from_snacks.picker.files
}, {
    __index = function (tbl, key)
        return rawget(tbl, key) or from_snacks.picker[key]
    end
})

local with_pickers = function (keys)
    for name, map in pairs(picker_mappings) do
        table.insert(keys, {
            map,
            picks[name](picker_opts[name]),
            desc = picker_opts[name].desc
        })
    end
    return keys
end

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
                        {
                            box = "horizontal",
                            { win = "list", border = "none" },
                            { win = "preview", title = "{preview}", width = 0.6, border = "left" },
                        },
                    },
                }
            }
        },
    },
    keys = with_pickers {
        { "<leader>wz", from_snacks.zen.zen() },
        { "<leader>wZ", from_snacks.zen.zoom() },
    }
}
