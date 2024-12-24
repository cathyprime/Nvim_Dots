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

                ["<C-p>"] = { "show", "select_prev", "fallback" },
                ["<C-n>"] = { "show", "select_next", "fallback" },

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
                -- use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
            },
            completion = {
                keyword = { range = "full" },
                accept = { auto_brackets = { enabled = false } },
                documentation = {
                    window = {
                        border = "single"
                    }
                },
                menu = {
                    max_height = 6,
                    auto_show = false,
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
                ghost_text = { enabled = true },
            },
            signature = { enabled = true },
        }
    }
}
