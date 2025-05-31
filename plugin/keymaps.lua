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

map("v", "<leader>d", [[:s#\(\S\)\s\+#\1 #g<cr>:noh<cr>]])

-- search
local search_map = function (tbl)
    vim.keymap.set("n", tbl[1], tbl[2], { expr = true })
end
local stable_search = function (forward)
    return function ()
        if forward then
            return vim.v.searchforward == 1 and "n" or "N"
        end
        return vim.v.searchforward == 0 and "n" or "N"
    end
end

search_map { "n",  stable_search(true)  }
search_map { "N",  stable_search(false) }

if vim.g.neovide then
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

require("cathy.substitute")
vim.keymap.set({ "n", "x" }, "gs", "<Plug>(substitute)")
vim.keymap.set("n", "gss", "<Plug>(substitute-linewise)")
vim.keymap.set("n", "gS", "<Plug>(substitute-file)")

vim.keymap.set("n", "<leader>r", require("cathy.tasks"), { desc = "Tasks" })

local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
local nxo = { "n", "x", "o" }
vim.keymap.set(nxo, ";", ts_repeat_move.repeat_last_move)
vim.keymap.set(nxo, ",", ts_repeat_move.repeat_last_move_opposite)
vim.keymap.set(nxo, "f", ts_repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set(nxo, "F", ts_repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set(nxo, "t", ts_repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set(nxo, "T", ts_repeat_move.builtin_T_expr, { expr = true })
