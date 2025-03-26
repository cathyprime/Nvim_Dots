vim.keymap.set(
    {"n", "i"},
    "<c-g>",
    function()
        vim.api.nvim_win_close(0, false)
        return "<esc>"
    end,
    { expr = true, buffer = true, silent = true }
)

local function map(modes, lhs, rhs)
    vim.keymap.set(modes, lhs, rhs, { buffer = true, silent = true })
end

map({"n", "i"}, "<c-c>",    "<esc><c-w>c")
map("i",        "<c-k>",           "<up>")
map("i",        "<c-j>",         "<down>")
map("i",        "<c-e>",          "<end>")
map("i",        "<c-a>",         "<home>")
map("n",        "<esc>", "<cmd>close<cr>")
map("n",        "<c-p>",          "<nop>")

local old_status = vim.opt.laststatus
local old_cmdheight = vim.opt.cmdheight
vim.opt_local.cursorline = false
vim.opt_local.spell = false
vim.opt_local.winbar = nil
vim.opt.laststatus = 0
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.scrolloff = 0
vim.opt_local.completeopt = "menu"
vim.opt.cmdheight = 0

vim.api.nvim_create_autocmd("BufEnter", {
    once = true,
    callback = function()
        vim.opt.foldmethod = "expr"
    end,
})

vim.api.nvim_create_autocmd("CmdwinLeave", {
    buffer = vim.api.nvim_get_current_buf(),
    once = true,
    callback = function()
        vim.opt.laststatus = old_status
        vim.opt.cmdheight = old_cmdheight
    end
})

vim.api.nvim_win_set_cursor(0, { vim.fn.line('$'), 0 })
