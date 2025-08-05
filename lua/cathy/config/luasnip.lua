local ok, ls = prot_require "luasnip"
if not ok then
    return
end

vim.keymap.set({ "i", "s" }, "<c-j>", function ()
    if vim.snippet.active() then
        vim.snippet.jump(1)
        return
    end
    if ls.expand_or_jumpable() then
        local ft = vim.o.filetype
        if not ft:match "commit" and not ft:match "Commit" then
            ls.expand_or_jump()
        else
            if ls.jumpable(1) then
                ls.jump(1)
            elseif ls.expandable() then
                ls.expand()
            end
        end
    end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<c-k>", function () ls.jump(-1) end, { silent = true })

vim.keymap.set({ "i", "s" }, "<c-l>", function ()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end, { silent = true })

local types = require("luasnip.util.types")

ls.config.setup({
    history = true,
    update_events = {"TextChanged", "TextChangedI"},
    enable_autosnippets = true,
    ext_opts = {
        [types.choiceNode] = {
            active = {
                virt_text = {{"●", "PortalOrange"}},
                hl_mode = "combine"
            }
        },
        [types.insertNode] = {
            active = {
                virt_text = {{"●", "PortalBlue"}},
                hl_mode = "combine"
            }
        }
    },
})

require("luasnip.loaders.from_lua").lazy_load({ paths = { "./lua/cathy/snippets" } })
