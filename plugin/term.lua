vim.api.nvim_create_autocmd("TermLeave", {
    command = "setlocal scl=yes:2"
})

vim.api.nvim_create_autocmd("TermEnter", {
    command = "setlocal scl=no"
})

vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        local map = require("cathy.utils").map_gen({
            buffer = buf,
            silent = true
        })
        map("t", "<c-space><esc>", [[<c-\><c-n>]])
        map("t", "<c-space>c", [[<c-\><c-n>]])
        map("t", "<c-space>q", [[<c-\><c-n>]])
        map("t", "<c-space>\"", function ()
            local char = vim.fn.nr2char(vim.fn.getchar())
            vim.api.nvim_paste(vim.fn.getreg(char), true, -1)
        end)
        map("t", "<c-space><c-w>", function ()
            vim.api.nvim_create_autocmd("BufEnter", {
                once = true,
                command = "startinsert",
                buffer = vim.api.nvim_get_current_buf()
            })
            local prev_window = vim.fn.win_getid(vim.fn.winnr("#"))
            vim.api.nvim_set_current_win(prev_window)
        end)
        map("t", "<s-space>", "<space>")
        map("t", "<c-space>", [[<c-\><c-o>]])
        map("t", "<c-bs>", "<c-w>")
        map("n", "gf", function()
            local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
            if f == "" then
                vim.notify(string.format([[E447: Can't find file "%s" in path]], vim.fn.expand("<cfile>")), vim.log.levels.ERROR, {})
            else
                pcall(vim.api.nvim_win_close, vim.api.nvim_get_current_win(), false)
                local term_job = vim.b[buf].terminal_job_id
                if term_job then
                    vim.fn.jobstop(term_job)
                end
                vim.schedule(function()
                    vim.cmd("e " .. f)
                end)
            end
        end)
    end,
})
