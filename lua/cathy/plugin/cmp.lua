local modes = {
    c = true,
    cr = true,
    cv = true,
    cvr = true,
}

function show(cmp)
    if not modes[vim.fn.mode()] then
        cmp.show()
    end
end

function select_gen(way)
    return function (cmp)
        if require("blink.cmp").is_visible() or not modes[vim.fn.mode()] then
            cmp["select_" .. way]()
            return true
        end
    end
end

return {
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "saghen/blink.cmp",
        version = "v0.*",
        opts = {
            keymap = {
                preset = "default",
                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },

                ["<C-b>"] = {},
                ["<C-f>"] = {},
                ["<tab>"] = {},
                ["<s-tab>"] = {},

                ["<C-p>"] = { show, select_gen("prev"), "fallback" },
                ["<C-n>"] = { show, select_gen("next"), "fallback" },

                ["<C-d>"] = { "scroll_documentation_down", "fallback" },
                ["<C-u>"] = { "scroll_documentation_up", "fallback" },
            },
            snippets = {
                expand = function(snippet) require("luasnip").lsp_expand(snippet) end,
                active = function(filter)
                    if filter and filter.direction then
                        return require("luasnip").jumpable(filter.direction)
                    end
                    return require("luasnip").in_snippet()
                end,
                jump = function(direction) require("luasnip").jump(direction) end,
            },
            appearance = {
                use_nvim_cmp_as_default = false,
                nerd_font_variant = "mono",
            },
            signature = { enabled = false },
            completion = {
                list = {
                    selection = function(ctx)
                        return ctx.mode == "cmdline" and "auto_insert" or "preselect"
                    end
                },
                keyword = { range = "prefix" },
                accept = { auto_brackets = { enabled = false } },
                documentation = {
                    treesitter_highlighting = true,
                    window = {
                        border = "single"
                    }
                },
                ghost_text = { enabled = true },
                menu = {
                    max_height = 6,
                    auto_show = function(ctx)
                        if ctx.mode == "cmdline" then
                            return #vim.fn.getcmdline() > 5 and true or false
                        end
                        return ctx.mode == "cmdline"
                    end,
                    draw = {
                        padding = 0,
                        components = {
                            kind_icon = {
                                ellipsis = false,
                                text = function(ctx) return " " .. ctx.kind_icon .. " " .. ctx.icon_gap end,
                                highlight = function(ctx)
                                    return require("blink.cmp.completion.windows.render.tailwind").get_hl(ctx) or 'BlinkCmpKind' .. ctx.kind
                                end,
                            },
                        }
                    }
                },
            },
        }
    }
}
