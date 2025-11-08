local ok, blink = prot_require "blink.cmp"
if not ok then
    return
end

local modes = {
    c = true,
    cr = true,
    cv = true,
    cvr = true,
}

local function show(cmp)
    if not modes[vim.fn.mode()] then
        cmp.show()
    end
end

local function select_gen(way)
    return function (cmp)
        if blink.is_visible() or not modes[vim.fn.mode()] then
            cmp["select_" .. way]()
            return true
        end
    end
end

local setup_blink = function ()
    blink.setup({
        fuzzy = {
            implementation = "rust"
        },
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
        appearance = {
            use_nvim_cmp_as_default = false,
            nerd_font_variant = "mono",
        },
        signature = { enabled = false },
        cmdline = {
            completion = {
                ghost_text = { enabled = true },
                menu = {
                    auto_show = function()
                        return #vim.fn.getcmdline() > 5 and true or false
                    end,
                    draw = {
                        columns = {
                            { "kind_icon", gap = 1 }, { "label", "label_description" },
                        },
                    }
                }
            }
        },
        completion = {
            list = {
                selection = {
                    preselect = true,
                    auto_insert = function(ctx)
                        return ctx.mode == "cmdline"
                    end
                }
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
                border = "none",
                max_height = 6,
                auto_show = false,
                draw = {
                    columns = {
                        { "kind_icon", gap = 1 }, { "label", "label_description", "pad", gap = 1 },
                    },
                    padding = 0,
                    treesitter = {
                        "lsp"
                    },
                    components = {
                        pad = {
                            text = function(ctx) return string.rep(" ", ctx.self.gap or 1) end,
                        },
                        kind_icon = {
                            text = function(ctx) return " " .. ctx.kind_icon .. " " .. ctx.icon_gap end,
                        },
                    }
                }
            },
        },
    })
end

vim.api.nvim_create_autocmd("InsertEnter", {
    once = true,
    callback = setup_blink
})
