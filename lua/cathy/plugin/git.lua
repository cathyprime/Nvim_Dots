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

return {
    {
        "sindrets/diffview.nvim",
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>" },
            { "<leader>gc", "<cmd>DiffviewClose<cr>" }
        },
        dependencies = "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
            require("diffview").setup({
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
    },
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim"
        },
        keys = {
            { "ZG",  function()
                local cwd = require("oil") and require("oil").get_current_dir()
                if cwd ~= nil then
                    require("neogit").open({ kind = "tab", cwd = cwd:sub(0, -1) })
                else
                    require("neogit").open({ kind = "tab" })
                end
            end }
        },
        config = true,
        opts = {
            integrations = {
                snacks = false
            }
        },
        init =  function()
            vim.api.nvim_create_autocmd("Filetype", {
                group = vim.api.nvim_create_augroup("cathy_neogit", { clear = true }),
                pattern = "Neogit*",
                command = "setlocal foldcolumn=0"
            })
        end
    },
}
