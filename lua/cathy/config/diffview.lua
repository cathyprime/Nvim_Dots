local ok, diffview = prot_require "diffview"
if not ok then
    return
end

setup_diffview = function ()
    ---@param options { forward: boolean, desc: string }
    ---@return { mode: string, lhs: string, rhs: function, opts: table }
    local function jump_diff(options)
        local repeatable_move = require("nvim-treesitter-textobjects.repeatable_move")
        local actions = require("diffview.actions")

        local wrapped = repeatable_move.make_repeatable_move(
            function (move_opts)
                if move_opts.forward then
                    actions.next_conflict()
                else
                    actions.prev_conflict()
                end
            end
        )
        local repeatable_forward = function () wrapped({ forward = true }) end
        local repeatable_backward = function () wrapped({ forward = false }) end
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
end

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = setup_diffview
})

vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>")
vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<cr>")
