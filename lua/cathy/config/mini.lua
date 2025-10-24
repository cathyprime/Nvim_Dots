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
    end,

    extra = function ()
        require("mini.extra").setup()
        local MiniPick = require("mini.pick")
        local MiniExtra = require("mini.extra")
        for name, picker in pairs(MiniExtra.pickers) do
            MiniPick.registry[name] = function(local_opts)
                local prompt_prefix
                if local_opts and local_opts.prompt_prefix then
                    prompt_prefix = local_opts.prompt_prefix
                    local_opts = vim.tbl_deep_extend("force", {}, local_opts)
                    local_opts.prompt_prefix = nil
                end
                local opts = {}
                if prompt_prefix then
                    opts.window = { prompt_prefix = prompt_prefix }
                end
                return picker(local_opts, opts)
            end
        end
    end,

    pick = function ()
        local win_config = function()
            local height = math.floor(0.5 * vim.o.lines)
            local width = vim.o.columns
            return {
                anchor = 'NW', height = height, width = width,
                row = vim.o.lines - height,
                col = math.floor(0.5 * (vim.o.columns - width)),
                border = { " ", "─", "─", " ", " ", " ", " ", " " }
            }
        end
        require("mini.pick").setup {
            window = {
                config = win_config,
                prompt_caret = " "
            }
        }
        for name, builtin in pairs(require("mini.pick").builtin) do
            MiniPick.registry[name] = function (local_opts)
                local prompt_prefix
                if local_opts and local_opts.prompt_prefix then
                    prompt_prefix = local_opts.prompt_prefix
                    local_opts.prompt_prefix = nil
                end
                local opts = {}
                if prompt_prefix then
                    opts.window = { prompt_prefix = prompt_prefix }
                end
                return builtin(local_opts, opts)
            end
        end

        vim.cmd [[hi! link MiniPickPrompt Normal]]
        vim.cmd [[hi! link MiniPickPromptCaret Cursor]]
        vim.cmd [[hi! link MiniPickPromptPrefix Normal]]

        MiniPick.registry.locpick = require("cathy.utils.mini.locpick")
        local pick = function (name)
            return function (prefix)
                return function ()
                    MiniPick.registry[name]({ prompt_prefix = prefix })
                end
            end
        end
        local map = function (lhs)
            return function (opts)
                vim.keymap.set("n", lhs, opts[1], { silent = true })
            end
        end

        map "<leader>ff"       { function () vim.cmd.Pick "locpick" end }
        map "<leader><leader>" { pick "files"        "Files :: " }
        map "<leader>fg"       { pick "grep_live"    "Grep :: " }
        map "<leader>fh"       { pick "help"         "Help :: " }
        map "<leader>b"        { pick "buffers"      "Buffers :: " }
        map "z="               { pick "spellsuggest" "Spelling :: " }
        map "<leader>fw" {
            function ()
                local word = vim.fn.expand("<cword>")
                MiniPick.registry.grep({
                    pattern = word,
                    prompt_prefix = word .. " >> Grep :: "
                })
            end
        }
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
                line_left  = "<m-h>",
                line_right = "<m-l>",
                line_down  = "<m-j>",
                line_up    = "<m-k>",
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
            vim.wo[win_src].scrollbind, vim.wo[win_src].scrollbind = true, true
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
                    local filename      = config.filename({ trunc_width = 110 })
                    local filetype      = config.filetype()
                    local last_button   = config.last_button({ trunc_width = 20 })
                    local diff          = config.diff({ trunc_width = 75 })
                    local diagnostics   = config.diagnostics({ trunc_width = 75 })
                    local cursor_pos    = config.cursor_pos_min({ trunc_width = 75 })
                    local five_hls      = config.mode_highlights()
                    local five_hls_b    = config.mode_highlightsB()
                    local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
                    local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })

                    return MiniStatusline.combine_groups({
                        { hl = 'MiniStatuslineDevinfoB', strings = { filename } },
                        "%=",
                        { hl = 'MiniStatuslineDevinfoB', strings = { last_button, search, diff } },
                        { hl = five_hls_b,               strings = { lsp, filetype, diagnostics } },
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

local setup_mini = function ()
    local load_mini = function (name, setup)
        local ok, mini = prot_require("mini." .. name)
        if not ok then
            return
        end
        setup()
    end

    vim.iter(minis)
        :each(load_mini)
end

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = setup_mini
})
