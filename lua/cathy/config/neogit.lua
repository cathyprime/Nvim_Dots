local ok, neogit = prot_require "neogit"
if not ok then
    return
end

vim.api.nvim_create_autocmd("Filetype", {
    group = vim.api.nvim_create_augroup("cathy_neogit", { clear = true }),
    pattern = "Neogit*",
    command = "setlocal foldcolumn=0"
})

neogit.setup({
    integrations = {
        snacks = false
    }
})

local open_neogit = function()
    local cwd = require("oil") and require("oil").get_current_dir()
    if cwd ~= nil then
        neogit.open({ kind = "tab", cwd = cwd:sub(0, -1) })
    else
        neogit.open({ kind = "tab" })
    end
end

vim.keymap.set("n", "ZG", open_neogit)
