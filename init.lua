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

vim.iter {
    "nvim-mini/mini.nvim",

    -- libs
    "nvim-lua/plenary.nvim",

    -- debug
    "mfussenegger/nvim-dap",
    "igorlfs/nvim-dap-view",

    -- git
    "NeogitOrg/neogit",
    "sindrets/diffview.nvim",

    -- misc
    "neovim/nvim-lspconfig",
    "stevearc/oil.nvim",
    "nvimtools/hydra.nvim",
    "chrishrb/gx.nvim",
    "milisims/nvim-luaref",
    "cbochs/grapple.nvim",

    -- editing
    "L3MON4D3/LuaSnip",
    "stevearc/quicker.nvim",
    "monaqa/dial.nvim",
    {
        source = "saghen/blink.cmp",
        version = "v1.7.0",
        hooks = {
            post_install = build_blink,
            post_checkout = build_blink,
        }
    },
    {
        source = "jake-stewart/multicursor.nvim",
        checkout = "1.0",
    },

    -- treesitter
    { source = "JoosepAlviste/nvim-ts-context-commentstring" },
    {
        source = "nvim-treesitter/nvim-treesitter",
        checkout = "main",
        hooks = {
            post_checkout = function() vim.cmd "TSUpdate" end
        },
    },
    {
        source = "nvim-treesitter/nvim-treesitter-textobjects",
        checkout = "main"
    },
}:each(require("mini.deps").add)
require "cathy.utils.persist_bg"
