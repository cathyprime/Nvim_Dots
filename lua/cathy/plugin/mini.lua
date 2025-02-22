local minis = {

    indentscope = function()
        require("mini.indentscope").setup({
            symbol = "",
        })
        vim.api.nvim_create_autocmd("BufEnter", {
            group = vim.api.nvim_create_augroup("cathy_indent_scope", { clear = true }),
            callback = function()
                if vim.opt.shiftwidth:get() <= 2 or vim.opt.tabstop:get() <= 2 then
                    vim.b.miniindentscope_config = {
                        symbol = "│"
                    }
                end
            end
        })
        vim.keymap.set("o", "o", function()
            local operator = vim.v.operator
            if operator == "d" then
                local scope = MiniIndentscope.get_scope()
                local top = scope.border.top
                local bottom = scope.border.bottom
                local row, col = vim.api.nvim_win_get_cursor(0)
                local move = ""
                if row == bottom then
                    move = "k"
                elseif row == top then
                    move = "j"
                end
                local ns = vim.api.nvim_create_namespace("border")
                vim.api.nvim_buf_add_highlight(0, ns, "Substitute", top - 1, 0, -1)
                vim.api.nvim_buf_add_highlight(0, ns, "Substitute", bottom - 1, 0, -1)
                vim.defer_fn(function()
                    vim.api.nvim_buf_set_text(0, top - 1, 0, top - 1, -1, {})
                    vim.api.nvim_buf_set_text(0, bottom - 1, 0, bottom - 1, -1, {})
                    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
                end, 150)
                return "<esc>" .. move
            else
                return "o"
            end
        end, { expr = true })
    end,

    operators = function()
        require("mini.operators").setup({
            sort = {
                prefix = "",
                func = nil,
            },
        })
    end,

    comment = function()
        require("mini.comment").setup({
            options = {
                custom_commentstring = function()
                    return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
                end,
            },
        })
    end,

    trailspace = function()
        require("mini.trailspace").setup()
    end,

    move = function()
        require("mini.move").setup({
            mappings = {
                left       = "<m-h>",
                right      = "<m-l>",
                down       = "<m-j>",
                up         = "<m-k>",
                line_left  = "",
                line_right = "",
                line_down  = "<m-j>",
                line_up    = "<m-k>",
            }
        })
        vim.keymap.set("n", "<m-h>", function ()
            vim.cmd.normal("v")
            require("mini.move").move_selection("left")
            vim.cmd.normal("v")
        end)
        vim.keymap.set("n", "<m-l>", function ()
            vim.cmd.normal("v")
            require("mini.move").move_selection("right")
            vim.cmd.normal("v")
        end)
    end,

    clue = function()
        local module = require("mini.clue")
        module.setup({
            triggers = {
                { mode = "n", keys = "<leader>f" },
                { mode = "i", keys = "<c-x>" },
                { mode = "n", keys = "<leader>go" },
                { mode = "v", keys = "<leader>go" },
            },
            clues = {
                module.gen_clues.builtin_completion(),
            }
        })
    end,

    misc = function()
        require("mini.misc").setup()
    end,

    splitjoin = function()
        require("mini.splitjoin").setup({
            mappings = {
                toggle = "<leader>s",
            }
        })
    end,

    ai = function()
        local module = require("mini.ai")
        module.setup({
            n_lines = 200,
            custom_textobjects = {
                o = module.gen_spec.treesitter({
                    a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                    i = { "@block.inner", "@conditional.inner", "@loop.inner" },
                }, {}),
                F = module.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
                c = module.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
                t = module.gen_spec.treesitter({ a = "@type.outer", i = "@type.inner" }, {})
            },
        })
    end,

    diff = function()
        local module = require("mini.diff")
        module.setup({
            mappings = {
                apply = "",
                reset = "",
            },
            view = {
                style = "sign",
                signs = {
                    add    = "",
                    change = "",
                    delete = "",
                },
                priority = -199,
            },
        })
        vim.keymap.set("n", "<leader>go", function()
            pcall(module.toggle_overlay)
        end)
    end,

    git = function()
        require("mini.git").setup()
        local align_blame = function(au_data)
            if au_data.data.git_subcommand ~= 'blame' then return end

            -- Align blame output with source
            local win_src = au_data.data.win_source
            vim.wo.wrap = false
            vim.fn.winrestview({ topline = vim.fn.line('w0', win_src) })
            vim.api.nvim_win_set_cursor(0, { vim.fn.line('.', win_src), 0 })
            vim.api.nvim_win_set_width(0, 56)

            -- Bind both windows so that they scroll together
            vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
        end

        local au_opts = { pattern = 'MiniGitCommandSplit', callback = align_blame }
        vim.api.nvim_create_autocmd('User', au_opts)
    end,

    statusline = function()
        require("mini.statusline").setup({
            content = {
                active = function()
                    local config = require("cathy.config.statusline")
                    local ok, ft = config.filetype_specific()
                    if ok then
                        return ft(true)
                    end
                    local mode          = config.mode({ trunc_width = 110 })
                    local mode_hl       = config.mode_highlights()
                    local filename      = config.filename({ trunc_width = 110 })
                    local recording     = config.recording({ trunc_width = 110 })
                    local recording_hl  = config.record_hl()
                    local last_button   = config.last_button({ trunc_width = 20 })
                    local diff          = config.diff({ trunc_width = 75 })
                    local diagnostics   = config.diagnostics({ trunc_width = 75 })
                    local cursor_pos    = config.cursor_pos_min({ trunc_width = 75 })
                    local five_hls      = config.mode_highlights()
                    local five_hls_b    = config.mode_highlightsB()
                    local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
                    local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })

                    local name_or_index = require("grapple").name_or_index()
                    local grapple       = name_or_index and string.format("g -> [%d]", name_or_index) or ""

                    return MiniStatusline.combine_groups({
                        { hl = mode_hl,                  strings = { mode } },
                        { hl = recording_hl,             strings = { recording } },
                        { hl = 'MiniStatuslineDevinfoB', strings = { filename } },
                        "%=",
                        { hl = 'MiniStatuslineDevinfoB', strings = { last_button, search, diff } },
                        { hl = five_hls_b,               strings = { grapple, lsp, diagnostics } },
                        { hl = five_hls,                 strings = { cursor_pos } },
                        "%P ",
                    })
                end,
                inactive = function()
                    local config = require("cathy.config.statusline")
                    local ok, ft = config.filetype_specific()
                    if ok then
                        return ft(false)
                    end
                    local filename   = config.filename({ trunc_width = 110 })
                    local cursor_pos = config.cursor_pos_min({ trunc_width = 75 })
                    return MiniStatusline.combine_groups({
                        { hl = 'MiniStatuslineDevinfoB', strings = { filename } },
                        "%=",
                        { strings = { cursor_pos } },
                        "%P ",
                    })
                end
            }
        })
    end,

    -- surround = function()
    --     local ts_input = require("mini.surround").gen_spec.input.treesitter
    --     require("mini.surround").setup({
    --         custom_surroundings = {
    --             t = {
    --                 input = ts_input({ outer = "@type.outer", inner = "@type.inner" }),
    --                 output = function()
    --                     local type_name = MiniSurround.user_input("Type name")
    --                     return { left = type_name.."<", right = ">" }
    --                 end
    --             },
    --             T = {
    --                 input = { '<(%w-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' },
    --                 output = function()
    --                     local tag_full = MiniSurround.user_input('Tag')
    --                     if tag_full == nil then return nil end
    --                     local tag_name = tag_full:match('^%S*')
    --                     return { left = '<' .. tag_full .. '>', right = '</' .. tag_name .. '>' }
    --                 end,
    --             },
    --         },
    --         mappings = {
    --             add = "s",
    --             delete = "sd",
    --             find = "",
    --             find_left = "",
    --             highlight = "",
    --             replace = "sc",
    --             update_n_lines = "",
    --             suffix_last = 'l',
    --             suffix_next = 'n',
    --         },
    --     })
    --     vim.keymap.set("n", "ss", "s_", { remap = true })
    --     vim.keymap.set("n", "S", "s", { remap = false })
    -- end,

    icons = function()
        require("mini.icons").setup()
        MiniIcons.mock_nvim_web_devicons()
    end

}

return {
    "echasnovski/mini.nvim",
    config = function()
        vim.iter(minis):each(function(_, fn) fn() end)
    end
}
