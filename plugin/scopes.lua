local scopes = require("cathy.scopes")

local fts = {
    man = true,
    [""] = true
}

vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = vim.api.nvim_create_augroup("Magda_Rooter", { clear = true }),
    pattern = "*",
    callback = function (env)
        if fts[vim.bo[env.buf].filetype] then
            return
        end
        local expand = vim.fn.expand("%:p:h")
        if expand:match "^term" then
            return
        end

        pcall(vim.cmd, "silent cd " .. scopes.get_root())
    end
})

vim.api.nvim_create_user_command("Scopes", scopes.edit_scopes, { nargs = 0 })
