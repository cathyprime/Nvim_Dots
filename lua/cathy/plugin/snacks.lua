require("cathy.utils.snacks.set_ui_select")
local from_snacks = require("cathy.utils.snacks.from_snacks")
local picker_opts = require("cathy.utils.snacks.picker_opts")
local f = require("cathy.utils.snacks.format")

local term = function ()
    local cwd = require("oil").get_current_dir()
    if not cwd then
        cwd = vim.uv.cwd()
    end
    Snacks.terminal(nil, {
        cwd = cwd,
        start_insert = true,
        auto_insert = false,
        auto_close = true,
        interactive = false
    })
end

local picker_mappings = {
    man          = "<leader>fm",
    undo         = "<leader>u",
    find_file    = "<leader>ff",
    jumps        = "<leader>fj",
    resume       = "<leader>fF",
    lazy         = "<leader>fl",
    grep         = "<leader>fg",
    grep_buffers = "<leader>fG",
    help         = "<leader>fh",
    grep_word    = "<leader>fw",
    smart        = "<leader><leader>",
    spelling     = "z=",
    projects     = "<leader>fp",
    explorer     = "<leader>fe"
}

local picks = setmetatable({
    find_file = require("cathy.utils.snacks.locpick"),
    spelling = function (opts)
        return function ()
            if vim.v.count ~= 0 then
                return vim.fn.feedkeys(vim.v.count .. "z=", 'n')
            end
            Snacks.picker.spelling(opts)
        end
    end
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
            desc = picker_opts[name] and picker_opts[name].desc or ""
        })
    end
    return keys
end

return {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        styles = {
            input = {
                backdrop = false,
                position = "float",
                border = "rounded",
                height = 1,
                width = math.floor(vim.opt.columns:get() / 1.2),
                relative = "editor",
                row = vim.opt.lines:get() - 5,
            }
        },
        terminal = {},
        bigfile = {
            notify = false,
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
        input = {
            icon = "",
            icon_hl = "SnacksInputIcon",
            icon_pos = "center",
            prompt_pos = "left",
        },
        gitbrowse = {},
        picker = {
            sources = {
                explorer = { format = "file" },
                files = {
                    finder = require("cathy.utils.snacks.remote_files").files
                }
            },
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
                ivy_noprev = {
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
                        },
                    },
                },
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
        { "<leader>wz",   from_snacks.zen.zen() },
        { "<leader>wZ",   from_snacks.zen.zoom() },
        { "<leader><cr>", term },
        { "<leader>gow",  from_snacks.gitbrowse.open({ what = "repo" }), mode = "n", desc = "repo" },
        { "<leader>gob",  from_snacks.gitbrowse.open({ what = "branch" }), mode = "n", desc = "branch" },
        { "<leader>gof",  from_snacks.gitbrowse.open({ what = "file" }), mode = { "n", "v" }, desc = "file" },
        { "<leader>gop",  from_snacks.gitbrowse.open({ what = "permalink" }), mode = { "n", "v" }, desc = "permalink" },
    }
}
