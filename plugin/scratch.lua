local function find_buffer_by_name(name)
    local bufs = vim.api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
        if vim.fn.bufname(buf) == name then
            return buf
        end
    end
end

local ft_settings = {
    sh = function(bufnr)
        vim.keymap.set("n", "<cr>", "mm<cmd>.!sh<cr>`m", { buffer = bufnr })
        vim.keymap.set("n", "<m-cr>", [[<cmd>redir @" | exec '.w !sh' | redir END<cr>]], { buffer = bufnr })
        vim.keymap.set("n", "gl", [[<cmd>%s#git@github.com:#https://github.com/<cr>]], { buffer = bufnr })
        vim.keymap.set("n", "gj", "<cmd>.!jq<cr>", { buffer = bufnr })
        vim.keymap.set("v", "<cr>", [[<cr>!sh<cr>]], { buffer = bufnr })
        vim.keymap.set("v", "<m-cr>", [[<cr>w !sh<cr>]], { buffer = bufnr })
    end,
    text = function()
        vim.keymap.set("n", "<cr>", [[<cmd>.!toilet --width 120 --font smblock<cr>]], { silent = true, buffer = bufnr })
    end,
    all = function()
        vim.keymap.set("n", "q", function()
            local ok = pcall(vim.api.nvim_win_close, vim.api.nvim_get_current_win(), false)
            if not ok then
                vim.cmd[[b#]]
            end
        end, { buffer = bufnr })
    end
}

local function set_filetype_opts(ft, bufnr)
    ft_settings.all(bufnr)
    if ft_settings[ft] ~= nil then
        ft_settings[ft](bufnr)
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
            buf = vim.api.nvim_create_buf(false, true)
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

vim.keymap.set("n", "<leader>os", "<cmd>Scratch<cr>", { desc = "open scratch buffer" })
vim.keymap.set("n", "<leader>oS", "<cmd>Scratch sh<cr>", { desc = "open scratch shell buffer" })
vim.keymap.set("n", "<leader>ot", "<cmd>Scratch markdown<cr>", { desc = "open scratch todo buffer" })
