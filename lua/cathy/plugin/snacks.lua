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

_G.dd = function(...)
  Snacks.debug.inspect(...)
end
_G.bt = function()
  Snacks.debug.backtrace()
end

local nopreview = with_layout { preview = false }
local mainprevw = with_layout { preview = "main" }

local picker_mappings = {
    undo         = "<leader>u",
    find_file    = "<leader>ff",
    jumps        = "<leader>fj",
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
    projects     = "<leader>fp",
    explorer     = "<leader>fe"
}

local picker_opts = {
    find_file    = { prompt = " Find file :: ", desc = "find file" },
    jumps        = { prompt = " Jumps :: ", desc = "jumps" },
    resume       = { desc = "resume" },
    explorer     = { desc = "explorer" },
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
        confirm = function (picker, item)
            local result = item.text
            picker:close()
            vim.cmd.cd(result)
            vim.cmd.edit(result)
        end,
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
            desc = picker_opts[name] and picker_opts[name].desc or ""
        })
    end
    return keys
end

local old_print = _G.print

print = function (...)
    local print_safe_args = {}
    local _ = { ... }
    for i = 1, #_ do
        table.insert(print_safe_args, tostring(_[i]))
    end
    vim.notify(table.concat(print_safe_args, ' '), "info")
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
        { "<leader>gow", from_snacks.gitbrowse.open({ what = "repo" }), mode = "n", desc = "repo" },
        { "<leader>gob", from_snacks.gitbrowse.open({ what = "branch" }), mode = "n", desc = "branch" },
        { "<leader>gof", from_snacks.gitbrowse.open({ what = "file" }), mode = { "n", "v" }, desc = "file" },
        { "<leader>gop", from_snacks.gitbrowse.open({ what = "permalink" }), mode = { "n", "v" }, desc = "permalink" },
    }
}
