vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
        local map = require("cathy.utils").map_gen({
            buffer = vim.api.nvim_get_current_buf(),
            silent = true
        })
        map("t", "<esc><esc>", [[<c-\><c-n>]])
        map("t", "<m-w>", [[<c-\><c-n><c-w>w]])
        map("t", "<s-space>", "<space>")
        map("t", "<c-bs>", "<c-w>")
    end,
})
