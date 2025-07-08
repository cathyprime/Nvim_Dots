vim.g.mapleader = " "
vim.g.localleader = [[\]]

function _G.lazy_require(module)
    return setmetatable({}, { __index = function (_, key)
        return require(module)[key]
    end})
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    vim.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "cathy.plugin" },
    },
    install = { colorscheme = { "habamax" } },
    checker = { enabled = false },
})
