local ok, diffview = prot_require "diffview"
if not ok then
    return
end

---@param options { forward: boolean, desc: string }
---@return { mode: string, lhs: string, rhs: function, opts: table }
local function jump_diff(options)
    local repeatable_move = require("nvim-treesitter.textobjects.repeatable_move")
    local actions = require("diffview.actions")

    local repeatable_forward, repeatable_backward =
        repeatable_move.make_repeatable_move_pair(
            actions.next_conflict,
            actions.prev_conflict
        )
    local key = options.forward and "]x" or "[x"
    local rhs = options.forward and repeatable_forward or repeatable_backward

    return { "n", key, rhs, { desc = options.desc } }
end

diffview.setup({
    keymaps = {
        view = {
            jump_diff({
                forward = true,
                desc = "In the merge-tool: jump to the next conflict",
            }),
            jump_diff({
                forward = false,
                desc = "In the merge-tool: jump to the previous conflict",
            })
        },
        file_panel = {
            jump_diff({
                forward = true,
                desc = "Go to the next conflict"
            }),
            jump_diff({
                forward = false,
                desc = "Go to the previous conflict"
            })
        }
    }
})

vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>")
vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<cr>")
