vim.g.mapleader = " "
vim.g.localleader = [[\]]
vim.cmd.colorscheme "cathy"

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
require("mini.deps").setup {
    path = {
        package = path_package
    }
}

local function build_blink(params)
    vim.notify("Building blink.cmp", vim.log.levels.INFO)
    vim.fn.jobstart({ "cargo", "build", "--release" }, {
        cwd = params.path,
        term = true
    })
end

local function berg(str)
    return ("https://codeberg.org/%s"):format(str)
end

local function gh(str)
    return ("https://github.com/%s"):format(str)
end

vim.iter {
    gh "nvim-mini/mini.nvim",

    -- libs
    gh "nvim-lua/plenary.nvim",

    -- debug
    berg "mfussenegger/nvim-dap",
    gh "igorlfs/nvim-dap-view",

    -- git
    gh "NeogitOrg/neogit",
    gh "sindrets/diffview.nvim",

    -- misc
    gh "neovim/nvim-lspconfig",
    gh "stevearc/oil.nvim",
    gh "nvimtools/hydra.nvim",
    gh "chrishrb/gx.nvim",
    gh "milisims/nvim-luaref",
    gh "cbochs/grapple.nvim",
    gh "tpope/vim-rsi",

    -- editing
    gh "L3MON4D3/LuaSnip",
    gh "stevearc/quicker.nvim",
    gh "monaqa/dial.nvim",
    {
        source = gh "saghen/blink.cmp",
        version = "v1.7.0",
        hooks = {
            post_checkout = build_blink,
        }
    },
    {
        source = gh "jake-stewart/multicursor.nvim",
        checkout = "1.0",
    },

    -- treesitter
    { source = gh "JoosepAlviste/nvim-ts-context-commentstring" },
    {
        source = gh "nvim-treesitter/nvim-treesitter",
        checkout = "main",
        hooks = {
            post_checkout = function() vim.cmd "TSUpdate" end
        },
    },
    {
        source = gh "nvim-treesitter/nvim-treesitter-textobjects",
        checkout = "main"
    },
}:each(require("mini.deps").add)
require "cathy.utils.persist_bg"
