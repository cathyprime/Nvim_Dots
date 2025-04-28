vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.bo.formatprg = "clang-format -style=file:" .. os.getenv("HOME") .. "/.config/.clang-format"
vim.opt_local.indentkeys = "0{,0},0),0],0#,!^F,o,O,e"
