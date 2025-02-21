local function jump_quickfix(options)
    return function()
        require("demicolon.jump").repeatably_do(function(opts)
            if opts.forward then
                vim.cmd([[execute "normal! \<Plug>(qf_qf_next)"]])
            else
                vim.cmd([[execute "normal! \<Plug>(qf_qf_previous)"]])
            end
        end, options)
    end
end

return {
    {
        "romainl/vim-qf",
        config = function()
            vim.g.qf_auto_quit = 0
            vim.g.qf_max_height = 12
            vim.g.qf_auto_resize = 0
            vim.g.qf_auto_open_quickfix = 0
        end
    },
    {
        "stevearc/quicker.nvim",
        ft = "qf",
        dependencies = "mawkler/demicolon.nvim",
        config = function()
            require("quicker").setup({
                keys = {
                    {
                        "<c-l>",
                        require("quicker").refresh,
                        desc = "Refresh quickfix list",
                    },
                    {
                        "+",
                        function()
                            require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
                        end,
                        desc = "Expand quickfix context"
                    },
                    {
                        "-",
                        require("quicker").collapse,
                        desc = "Collapse quickfix context"
                    }
                },
            })
        end,
        keys = {
            {
                "]c",
                jump_quickfix({ forward = true }),
                desc = "Next quickfix item"
            },
            {
                "[c",
                jump_quickfix({ forward = false }),
                desc = "Prev quickfix item"
            },
            { "<leader>q", function()
                if vim.g.dispatch_ready then
                    vim.cmd("Copen")
                else
                    require("quicker").toggle()
                end
            end }
        }
    }
}
