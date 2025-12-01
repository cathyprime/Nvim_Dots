local ok, oil = prot_require "oil"
if not ok then
    return
end

local permission_hlgroups = {
    ["-"] = "NonText",
    ["r"] = "DiffChanged",
    ["w"] = "DiffDeleted",
    ["x"] = "DiffAdded",
}

oil.setup({
    default_file_explorer = true,
    skip_confirm_for_simple_edits = true,
    columns = {
        {
            "permissions",
            highlight = function(permission_str)
                local hls = {}
                for i = 1, #permission_str do
                    local char = permission_str:sub(i, i)
                    table.insert(hls, { permission_hlgroups[char], i - 1, i })
                end
                return hls
            end,
        },
        { "size", highlight = "DiffAdded" },
        { "mtime", highlight = "Function" },
        "icon",
    },
    keymaps = {
        ["gx"] = false,
        ["gX"] = { "<cmd>Browse<cr>", desc = "open in browser" },
        ["<A-cr>"] = "actions.open_external",
        ["q"] = { function ()
            local ok, _ = pcall(vim.cmd.close)
            if not ok then
                vim.cmd.bdelete()
            end
        end, desc = "close buffer" },
        ["<leader><cr>"] = { function()
            local dir = require("oil").get_current_dir()
            vim.cmd("sp")
            vim.cmd("lcd " .. vim.fn.fnameescape(dir))
            vim.cmd("term")
            vim.cmd("startinsert")
        end, desc = "open terminal in split" },
        ["<C-q>"] = "actions.send_to_qflist",
        ["gy"] = "actions.yank_entry",
        ["!"] = { function()
            local parsed_name = require("oil").get_cursor_entry().parsed_name
            local cb = function (input)
                if not input then return end
                require("cathy.compile") {
                    cmd = string.format("%s %s", input, parsed_name),
                    cwd = require("oil").get_current_dir()
                }
            end
            vim.ui.input({
                prompt = string.format("! on %s: ", parsed_name)
            }, cb)
        end, desc = "perform an action on item" },
        ["cd"] = "actions.cd",
        ["<C-p>"] = false,
        ["g\\"] = false,
        ["gs"] = false,
        ["~"] = false,
        ["<C-h>"] = false,
        ["`"] = false,
    },
    view_options = {
        natural_order = true,
        show_hidden = true,
        is_always_hidden = function(name)
            return name == ".."
        end,
    },
})
vim.keymap.set("n", "<leader>d", "<cmd>sp | Oil<cr>")
vim.keymap.set("n", "-", "<cmd>Oil<cr>")
