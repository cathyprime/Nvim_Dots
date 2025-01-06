local disable_func = function(lang, buf)
    local max_filesize = 100 * 1024 -- 100kb
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats and stats.size > max_filesize then
        return true
    end
end

---@diagnostic disable-next-line
require("nvim-treesitter.configs").setup({
    auto_install = true,
    context_commentstring = { enabled = true },
    sync_install = false,
    ensure_installed = {
        "bash",
        "diff",
        "gitattributes",
        "gitcommit",
        "git_config",
        "gitignore",
        "git_rebase",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "vimdoc",
    },
    highlight = {
        enable = true,
        disable = disable_func,
        additional_vim_regex_highlighting = true,
    },
    indent = {
        enable = true,
        disable = disable_func,
    },
    incremental_selection = {
        enable = true,
        disable = disable_func,
        keymaps = {
            node_incremental = "<c-w>",
            node_decremental = "<c-e>",
            scope_incremental = "<c-s>",
        }
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            include_surrounding_whitespace = true,
            keymaps = { },
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                ["]l"] = { query = "@loop.outer", desc = "Goto next start loop" },
                ["]]"] = { query = "@function.outer", desc = "Goto next start function" },
            },
            goto_next_end = {
                ["]L"] = { query = "@loop.outer", desc = "Goto next end loop" },
                ["]["] = { query = "@function.outer", desc = "Goto next end function" },
            },
            goto_previous_start = {
                ["[l"] = { query = "@loop.outer", desc = "Goto prev start loop" },
                ["[["] = { query = "@function.outer", desc = "Goto prev start function" },
            },
            goto_previos_end = {
                ["[L"] = { query = "@loop.outer", desc = "Goto prev end loop" },
                ["[]"] = { query = "@function.outer", desc = "Goto prev end function" },
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ["g>"] = { query = { "@parameter.inner", "@call.outer", "@function.outer", "@class.outer" } },
            },
            swap_previous = {
                ["g<"] = { query = { "@parameter.inner", "@call.outer", "@function.outer", "@class.outer" } },
            }
        }
    }
})

