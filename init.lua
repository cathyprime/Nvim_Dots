vim.g.mapleader = " "
vim.g.localleader = [[\]]
vim.cmd.colorscheme "kanagawa"

function _G.lazy_require(module)
    return setmetatable({}, { __index = function (_, key)
        return require(module)[key]
    end})
end

function _G.prot_require(module_name)
    local ok, module = pcall(require, module_name)
    if not ok then
        vim.notify(module_name .. " not found!", vim.log.levels.WARN)
    end
    return ok, module
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    vim.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

local trans = setmetatable({
    cs = "c_sharp"
}, { __index = function (tbl, key) return key end})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(e)
        if vim.treesitter.language.add(trans[e.match]) then
            vim.treesitter.start()
            vim.opt.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})

require("lazy").setup({
    spec = {
        "chrishrb/gx.nvim",
        "nvim-mini/mini.nvim",
        "JoosepAlviste/nvim-ts-context-commentstring",
        "kylechui/nvim-surround",
        "L3MON4D3/LuaSnip",
        "mfussenegger/nvim-dap",
        "milisims/nvim-luaref",
        "monaqa/dial.nvim",
        "NeogitOrg/neogit",
        "sindrets/diffview.nvim",
        "neovim/nvim-lspconfig",
        "nvim-lua/plenary.nvim",
        "nvim-neotest/nvim-nio",
        "nvimtools/hydra.nvim",
        "rcarriga/nvim-dap-ui",
        "stevearc/oil.nvim",
        "stevearc/quicker.nvim",

        { "saghen/blink.cmp", version = "1.*" },
        { "jake-stewart/multicursor.nvim", branch = "1.0", },
        { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", branch = "main" },
        { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
        {
            "folke/snacks.nvim",
            lazy = false,
            priority = 1000,
        }
    },
    checker = { enabled = false },
})
