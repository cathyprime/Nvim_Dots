local buf = vim.api.nvim_get_current_buf()
vim.api.nvim_set_option_value("tabstop", 4, { buf = buf })
vim.api.nvim_set_option_value("shiftwidth", 4, { buf = buf })
vim.api.nvim_set_option_value("expandtab", true, { buf = buf })
