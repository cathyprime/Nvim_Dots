---@param options { forward: boolean, desc: string }
---@return { mode: string, lhs: string, rhs: function, opts: table }
local function jump_diff(options)
    local actions = require("diffview.actions")
    local key = options.forward and "]x" or "[x"
    return {"n", key, function()
        require("demicolon.jump").repeatably_do(function(opts)
            if opts.forward then
                actions.next_conflict()
            else
                actions.prev_conflict()
            end
        end, { forward = options.forward })
    end, { desc = options.desc }}
end

return {
    {
        "sindrets/diffview.nvim",
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>" },
            { "<leader>gc", "<cmd>DiffviewClose<cr>" }
        },
        dependencies = "mawkler/demicolon.nvim",
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
