require("cathy.utils.snacks.set_ui_select")
local from_snacks = require("cathy.utils.snacks.from_snacks")
local picker_opts = require("cathy.utils.snacks.picker_opts")

local picker_mappings = {
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
    find_file = require("cathy.utils.snacks.find_file"),
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
            notification_history = {
                border = "rounded",
                zindex = 100,
                width = 0.8,
                height = 0.8,
                minimal = false,
                title = " Notification History ",
                title_pos = "center",
                ft = "markdown",
                bo = { filetype = "snacks_notif_history", modifiable = false },
                wo = { winhighlight = "Normal:SnacksNotifierHistory" },
                keys = { q = "close" },
            }
        },
        terminal = {},
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
        gitbrowse = {},
        picker = {
            sources = { explorer = { format = "file" } },
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
        { "<leader><cr>", from_snacks.terminal() },
        { "<leader>gow",  from_snacks.gitbrowse.open({ what = "repo" }), mode = "n", desc = "repo" },
        { "<leader>gob",  from_snacks.gitbrowse.open({ what = "branch" }), mode = "n", desc = "branch" },
        { "<leader>gof",  from_snacks.gitbrowse.open({ what = "file" }), mode = { "n", "v" }, desc = "file" },
        { "<leader>gop",  from_snacks.gitbrowse.open({ what = "permalink" }), mode = { "n", "v" }, desc = "permalink" },
    }
}
