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

local picker_opts = {
    resume       = { desc = "resume" },
    explorer     = { desc = "explorer" },
    find_file    = { prompt = " Find file :: ",              desc = "find file" },
    jumps        = { prompt = " Jumps :: ",                  desc = "jumps" },
    spelling     = { prompt = " Spelling :: ",               desc = "spell suggestion", layout = { preset = "ivy_noprev" } },
    undo         = mainprevw { prompt = " Undo :: ",         desc = "undo" },
    lazy         = nopreview { prompt = " Lazy :: ",         desc = "lazy declarations" },
    grep         = nopreview { prompt = " Grep :: ",         desc = "grep" },
    grep_buffers = nopreview { prompt = " Grep Buffers :: ", desc = "grep current file" },
    help         = nopreview { prompt = " Help Tags :: ",    desc = "help" },
    grep_word    = nopreview { prompt = ">>= Grep :: ",      desc = "cursor grep" },
    smart        = nopreview {
        prompt = " Files :: ",
        desc = "files",
        multi = { "buffers", "files" },
        actions = {
            open_buffers = function (picker)
                Snacks.picker.buffers(nopreview {
                    prompt = " Buffers :: "
                })
            end
        },
        win = {
            input = {
                keys = {
                    ["<c-space>"] = { "open_buffers", mode = { "n", "i" }, desc = "Open buffers" },
                    ["<c-f>"] = { "open_find_file", mode = { "n", "i" }, desc = "Open Find File" }
                }
            }
        },
        actions = {
            open_find_file = function (picker)
                local cwd = picker:cwd() .. "/"
                picker:close()
                local find_file = require("cathy.utils.snacks.find_file")({
                    prompt = " Find file :: ",
                    cwd = cwd
                })
                find_file()
            end
        }
    },
    projects = nopreview {
        prompt = " Projects :: ",
        dev = { "~/polygon", "~/langs", "~/Repositories/" },
        format = f,
        desc = "projects",
        actions = {
            ["picker_grep"]   = cb_maker("grep",   nopreview { prompt = " Grep :: " }),
            ["picker_files"]  = cb_maker("files",  nopreview { prompt = " Find Files :: " }),
            ["picker_recent"] = cb_maker("recent", nopreview { prompt = " Oldfiles :: ", format = f }),
        },
        confirm = function (picker, item)
            local result = item.text
            picker:close()
            vim.cmd.cd(result)
            vim.cmd.edit(result)
        end,
    },
}

return picker_opts
