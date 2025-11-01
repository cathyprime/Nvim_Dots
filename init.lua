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

-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
    vim.cmd([[echo "Installing mini.nvim" | redraw]])
    local clone_cmd = {
        "git", "clone", "--filter=blob:none",
        "https://github.com/nvim-mini/mini.nvim", mini_path
    }
    vim.fn.system(clone_cmd)
    vim.cmd("packadd mini.nvim | helptags ALL")
    vim.cmd([[echo "Installed mini.nvim" | redraw]])
end
require('mini.deps').setup({ path = { package = path_package } })

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

local plugins = {
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

    {
        source = "saghen/blink.cmp",
        version = "v1.7.0"
    },
    {
        source = "jake-stewart/multicursor.nvim",
        checkout = "1.0",
    },
    {
        source = "nvim-treesitter/nvim-treesitter",
        checkout = "main",
        hooks = {
            post_install = function () vim.cmd "TSUpdate" end,
            post_checkout = function () vim.cmd "TSUpdate" end
        }
    },
    {
        source = "nvim-treesitter/nvim-treesitter-textobjects",
        checkout = "main"
    },
}

for _, spec in ipairs(plugins) do
    require("mini.deps").add(spec)
end
