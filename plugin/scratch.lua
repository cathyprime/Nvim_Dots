local function find_buffer_by_name(name)
    local bufs = vim.api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
        if vim.fn.bufname(buf) == name then
            return buf
        end
    end
end

local ft_settings = {
    sh = function(map)
        map("n", "<cr>", "mm<cmd>.!sh<cr>`m")
        map("n", "<m-cr>", [[<cmd>redir @" | exec '.w !sh' | redir END<cr>]])
        map("n", "gl", [[<cmd>%s#git@github.com:#https://github.com/<cr>]])
        map("n", "gj", "<cmd>.!jq<cr>")
        map("v", "<cr>", [[<cr>!sh<cr>]])
        map("v", "<m-cr>", [[<cr>w !sh<cr>]])
    end,
    lua = function (map)
        map("n", "<cr>", "<cmd>.source<cr>")
        map("x", "<cr>", ":<c-u>'<,'>source<cr>")
    end,
    all = function(map)
        map("n", "q", function()
            local ok = pcall(vim.api.nvim_win_close, vim.api.nvim_get_current_win(), false)
            if not ok then
                vim.cmd[[b#]]
            end
        end)
    end
}

local function set_filetype_opts(ft, bufnr)
    local buf_map = function (mode, lhs, rhs, opts)
        opts = opts or {}
        opts.buffer = true
        vim.keymap.set(mode, lhs, rhs, opts)
    end
    ft_settings.all(buf_map)
    if ft_settings[ft] ~= nil then
        ft_settings[ft](buf_map)
    end
end

vim.api.nvim_create_user_command(
    "Scratch",
    function(opts)
        local ft
        if #opts.fargs ~= 0 then
            local args = opts.fargs[1]
            ft = args
        else
            ft = vim.api.nvim_get_option_value("filetype", {
                buf = 0,
            })
        end
        if not opts.bang then
            vim.cmd(opts.mods .. " split")
        end

        local buf = find_buffer_by_name("Scratch://" .. ft)
        if buf == nil then
            buf = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_buf_set_name(buf, "Scratch://" .. ft)
            vim.bo[buf].bufhidden = "hide"
            vim.bo[buf].swapfile = false
            vim.bo[buf].buftype = "nofile"
            vim.bo[buf].filetype = ft
            set_filetype_opts(ft, buf)
        end

        vim.api.nvim_win_set_buf(0, buf)
    end,
    {
        bang = true,
        nargs = '?',
        complete = "filetype",
        desc = "Open a scratch buffer"
    }
)

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function ()
        local orig = vim.api.nvim_get_current_buf()
        vim.cmd.Scratch { bang = true, args = { "lua" } }
        vim.api.nvim_buf_delete(orig, { force = true, unload = false })
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            "-- this buffer is for text that will not be saved and for evaluating lua code",
            "-- to visit file use <space>ff and navigate to your project and edit that",
            "",
            "",
        })
        vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(0), 0 })
    end
})

vim.keymap.set("n", "<leader>os", "<cmd>Scratch<cr>", { desc = "open scratch buffer" })
vim.keymap.set("n", "<leader>oS", "<cmd>Scratch sh<cr>", { desc = "open scratch shell buffer" })
vim.keymap.set("n", "<leader>ot", "<cmd>Scratch markdown<cr>", { desc = "open scratch todo buffer" })
