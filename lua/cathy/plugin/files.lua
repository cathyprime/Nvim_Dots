local permission_hlgroups = {
    ["-"] = "NonText",
    ["r"] = "DiffChange",
    ["w"] = "DiffDelete",
    ["x"] = "DiffAdd",
}

return {
    "stevearc/oil.nvim",
    config = function()
        require("oil").setup({
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
                { "size", highlight = "DiffAdd" },
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
                ["<C-q>"] = "actions.send_to_qflist",
                ["gy"] = "actions.yank_entry",
                ["!"] = { function()
                    local parsed_name = require("oil").get_cursor_entry().parsed_name
                    local ok, cmd = pcall(vim.fn.input, {
                        prompt = string.format("! on %s: ", parsed_name),
                        cancelreturn = nil,
                    })
                    if not ok or cmd == nil then return end
                    vim.cmd.Start(string.format("-dir=%s -wait=always %s %s", require("oil").get_current_dir(), cmd, parsed_name))
                end, desc = "perform an action on item" },
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
        local locpick_oil = function ()
            require("cathy.utils.snacks.locpick") {
                pwd = require("cathy.utils").cur_buffer_path(),
                prompt = " Open directory :: ",
                cb = function (opts)
                    local edit_cmd = {
                        edit    = "buffer",
                        split   = "sp",
                        vsplit  = "vert sp",
                        tab     = "tabnew",
                        drop    = "drop",
                        tabdrop = "tab drop",
                    }
                    local edit = edit_cmd[opts.action.cmd]
                    if edit then
                        vim.cmd(edit .. " | Oil " .. opts.result)
                        return
                    end
                    vim.cmd("sp | Oil " .. opts.result)
                end
            }()
        end
        vim.keymap.set("n", "<leader>d", locpick_oil)
        vim.keymap.set("n", "-", "<cmd>Oil<cr>")
    end,
}
