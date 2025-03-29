local map = require("cathy.utils").map_gen({ silent = true })

local jump = function(direction)
    local ret = ""
    if vim.v.count ~= 0 then
        ret = "m'" .. vim.v.count
    else
        ret = "g"
    end
    return ret .. direction
end

local find_if_modified = function()
    return vim.iter(vim.api.nvim_list_bufs()):any(function(buffer)
        return vim.api.nvim_get_option_value("modified", { buf = buffer }) and vim.api.nvim_buf_is_loaded(buffer)
    end)
end

-- macro
vim.keymap.set("x", "@", function()
    local char = vim.fn.nr2char(vim.fn.getchar())
    vim.api.nvim_feedkeys(vim.keycode"<ESC>", 'x', false)
    local start = vim.fn.getpos("'<")[2]
    local stop = vim.fn.getpos("'>")[2]
    local ns = vim.api.nvim_create_namespace("macro_lines")
    for x = start,stop do
        vim.api.nvim_buf_set_extmark(0, ns, x, 0, {
            id = x + 1
        })
    end
    local consume_marks = function(marks)
        if #marks == 0 then return end
        local cur = marks[1]
        vim.api.nvim_buf_del_extmark(0, ns, cur[1])
        vim.schedule_wrap(vim.cmd)(cur[2] .. "norm @" .. char)
        vim.schedule_wrap(consume_marks)(vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {}))
    end
    local x = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
    consume_marks(x)
end)

map("n", "gQ", "qqqqq") -- clear q register and start recording (useful for recursive macros)

-- matchit plugin descriptions
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        map("n", "]%", "<Plug>(MatchitNormalMultiForward)", { desc = "Next unmatched group" })
        map("n", "[%", "<Plug>(MatchitNormalMultiBackward)", { desc = "Prev unmatched group" })
    end,
})

-- quickfix commands
if vim.g.loaded_dispatch ~= 1 then
    map("n", "<leader>q", "<cwd>cope<cr>")
end
-- if not package.loaded["demicolon"] then
--     map("n", "]c", "<Plug>(qf_qf_next)", { desc = "Next quickfix item" })
--     map("n", "[c", "<Plug>(qf_qf_previous)", { desc = "Prev quickfix item" })
--     map("n", "]C", "<Plug>(qf_qf_previous)", { desc = "Prev quickfix item" })
--     map("n", "[C", "<Plug>(qf_qf_next)", { desc = "Next quickfix item" })
-- end

-- scrolling
map("n", "<c-b>", "<Nop>")

-- text objects
-- inner underscore
map("o", "i_", ":<c-u>norm! T_vt_<cr>")
map("x", "i_", ":<c-u>norm! T_vt_<cr>")
-- a underscore
map("o", "a_", ":<c-u>norm! F_vf><cr>")
map("x", "a_", ":<c-u>norm! F_vf_<cr>")

-- clipboard
map({ "n", "v" }, "<leader>y", [["+y]])
map({ "n", "v" }, "<leader>gy", "<cmd>:%y+<cr>")
map({ "n", "v" }, "<leader>Y", [["+y$]])
map({ "n", "v" }, "<leader>p", [["+p]])
map({ "n", "v" }, "<leader>P", [["+P]])

-- save
map("n", "ZQ", "ZZ")
map("n", "ZZ", "<Nop>")

-- misc
map("n", "U", "<cmd>:earlier 1f<cr>")
map("n", "X", [[0"_D]])
map("x", "X", [[:norm 0"_D<cr>]])
map("n", "gp", "`[v`]")
map("n", "j", function()
    return jump("j")
end, { expr = true })
map("n", "k", function()
    return jump("k")
end, { expr = true })
map("x", "<leader>;", [[<cmd>'<,'>norm A;<cr>]])
map("n", "<c-z>", "<Nop>")
map("n", "<c-,>", function() -- duplicate line and stay in the same pos
    if not vim.opt_local.modifiable:get() then return end
    local pos = vim.api.nvim_win_get_cursor(0)
    local lines = vim.api.nvim_buf_get_lines(0, pos[1]-1, pos[1], true)
    pos[1] = pos[1] + 1
    vim.api.nvim_buf_set_lines(0, pos[1]-1, pos[1]-1, true, lines)
    vim.api.nvim_win_set_cursor(0, pos)
end)

-- command line
map("c", "<c-a>", "<home>", { silent = false })
map("c", "<m-f>", "<c-right>", { silent = false })
map("c", "<m-b>", "<c-left>", { silent = false })
map("c", "<c-k>", function()
    local line = vim.fn.getcmdline()
    local pos = vim.fn.getcmdpos()
    vim.fn.setcmdline(line:sub(0, pos - 1))
end, { silent = false })

vim.keymap.set("ca", "G", "Git")
map("c", "<c-space>", function()
    local cmdtype = vim.fn.getcmdtype()
    if cmdtype == "/" or cmdtype == "?" then
        return ".\\{-}"
    end
    return " "
end, { silent = false, expr = true })

map("v", "<leader>d", [[:s#\(\S\)\s\+#\1 #g<cr>:noh<cr>]])

-- search
local search_map = function (tbl)
    vim.keymap.set("n", tbl[1], tbl[2], { expr = true })
end
local stable_search = function (forward)
    return function ()
        -- vim.opt.hlsearch = true
        if forward then
            return vim.v.searchforward == 1 and "n" or "N"
        end
        return vim.v.searchforward == 0 and "n" or "N"
    end
end

search_map { "n",  stable_search(true)  }
search_map { "N",  stable_search(false) }

if vim.g.neovide then
    local change_scale_factor = function()
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
    end
    local resize = function(lhs, delta)
        vim.keymap.set("n", lhs, function()
            if delta == 1.0 then
                vim.g.neovide_scale_factor = 1.0
                return
            end
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
        end)
    end
    resize("<c-+>", 1.05)
    resize("<c-->", 1/1.05)
    resize("<c-ScrollWheelUp>", 1.15)
    resize("<c-ScrollWheelDown>", 1/1.15)
    resize("<C-=>", 1.0)
end
