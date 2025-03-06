local ft_settings = {
    sh = function()
        vim.keymap.set("n", "<cr>", "mm<cmd>.!sh<cr>`m", { buffer = true })
        vim.keymap.set("n", "<m-cr>", [[<cmd>redir @" | exec '.w !sh' | redir END<cr>]], { buffer = true })
        vim.keymap.set("n", "gl", [[<cmd>%s#git@github.com:#https://github.com/<cr>]], { buffer = true })
        vim.keymap.set("n", "gj", "<cmd>.!jq<cr>", { buffer = true })
        vim.keymap.set("v", "<cr>", [[<cr>!sh<cr>]], { buffer = true })
        vim.keymap.set("v", "<m-cr>", [[<cr>w !sh<cr>]], { buffer = true })
    end,
    text = function()
        vim.keymap.set("n", "<cr>", [[<cmd>.!toilet --width 120 --font smblock<cr>]], { silent = true, buffer = true })
    end,
    all = function()
        vim.keymap.set("n", "q", function()
            local ok = pcall(vim.api.nvim_win_close, vim.api.nvim_get_current_win(), false)
            if not ok then
                vim.cmd[[b#]]
            end
        end, { buffer = true })
    end
}

local function set_filetype_opts(ft)
    ft_settings.all()
    if ft_settings[ft] ~= nil then
        ft_settings[ft]()
    end
end

vim.api.nvim_create_user_command(
    "Afk",
    function(opts)
        local cur = vim.api.nvim_get_current_win()
        vim.cmd[[4split]]
        vim.cmd.enew()
        vim.api.nvim_set_option_value("buftype", "nofile", { buf = 0 })
        vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = 0 })
        vim.api.nvim_set_option_value("swapfile", false, { buf = 0 })
        vim.api.nvim_set_option_value("filetype", "AFK", { buf = 0 })
        vim.api.nvim_buf_set_name(0, "AFK -> " .. opts.args)
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { opts.args })
        vim.cmd("1!toilet --font smblock --width 120")
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
        vim.opt_local.relativenumber = false
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.signcolumn = "no"
        vim.opt_local.cursorline = false
        vim.opt_local.number = false
        local offset = vim.iter(lines)
            :map(function(line) return vim.fn.strdisplaywidth(line) end)
            :fold(0, function(acc, el)
                if acc > el then
                    return acc
                else
                    return el
                end
            end)
        offset = math.floor((vim.api.nvim_win_get_width(0) - offset) / 2) + 1
        local padding = string.rep(" " ,offset)
        lines = vim.iter(lines):map(function(line)
            return padding .. line
        end):totable()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
        vim.api.nvim_set_current_win(cur)
    end,
    {
        desc = "display afk message",
        nargs = 1
    }
)

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

        local buf = vim.iter(vim.api.nvim_list_bufs())
            :find(function(buf)
                return vim.fn.bufname(buf) == "Scratch -> " .. ft
            end)

        if buf ~= nil then
            vim.api.nvim_win_set_buf(0, buf)
            return
        end

        vim.cmd"enew"
        vim.api.nvim_set_option_value("buftype", "nofile", { buf = 0 })
        vim.api.nvim_set_option_value("bufhidden", "hide", { buf = 0 })
        vim.api.nvim_set_option_value("swapfile", false, { buf = 0 })
        if ft == [[nil]] or ft == [[""]] then
            return
        end
        vim.api.nvim_buf_set_name(0, "Scratch -> " .. ft)
        vim.api.nvim_set_option_value("filetype", ft, { buf = 0 })
        set_filetype_opts(ft)
    end,
    {
        bang = true,
        nargs = '?',
        complete = "filetype",
        desc = "Open a scratch buffer"
    }
)

vim.keymap.set("n", "<leader>oS", "<cmd>Scratch<cr>", { desc = "open scratch buffer" })
vim.keymap.set("n", "<leader>os", "<cmd>Scratch sh<cr>", { desc = "open scratch shell buffer" })
vim.keymap.set("n", "<leader>ot", "<cmd>Scratch markdown<cr>", { desc = "open scratch todo buffer" })
