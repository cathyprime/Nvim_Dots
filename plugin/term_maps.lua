vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        local map = require("cathy.utils").map_gen({
            buffer = buf,
            silent = true
        })
        local esc_timer
        map("t", "<m-w>", [[<c-\><c-n><c-w>w]])
        map("t", "<s-space>", "<space>")
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
        map("t", "<esc>", function()
            esc_timer = esc_timer or vim.uv.new_timer()
            if esc_timer:is_active() then
                esc_timer:stop()
                return [[<c-\><c-n>]]
            else
                esc_timer:start(200, 0, function() end)
                return "<esc>"
            end
        end, { expr = true })
    end,
})
