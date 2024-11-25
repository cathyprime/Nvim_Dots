local ok, _ = pcall(require, "telescope")
if not ok then
    local empty = function()
        vim.notify("failed to load telescope, try restarting neovim Kappa", vim.log.levels.ERROR)
    end
    return {
        project_files = empty,
        change_dir = empty,
        get_nvim = empty,
        hidden = empty,
        get_word = empty
    }
end

local builtin = require "telescope.builtin"
local config  = require "cathy.utils.telescope.config"

local M = {}

M.project_files = function()
    local p = require("project_nvim.project")
    local root = p.get_project_root()

    if root then
        M.find_files()
    else
        require("telescope").extensions.projects.projects()
    end
end

M.find_files = function()
    require("telescope.builtin").find_files({
        file_ignore_patterns = config.ignores,
        hidden = true,
        previewer = false,
    })
end

M.buffers = function()
    require("telescope.builtin").buffers({
        previewer = false,
        ignore_current_buffer = true,
    })
end

M.get_nvim = function()
    builtin.find_files({
        cwd = "~/.config/nvim",
        previewer = false,
    })
end

M.grep_current_file = function()
    require("telescope.builtin").live_grep({
        search_dirs = { vim.fn.expand("%:p") },
    })
end

---@deprecated
M.file_browser = function()
    error "picker deprecated"
    local pph = vim.fn.expand("%:p:h")
    if pph:find("term://") then
        pph = pph:gsub("term://", ""):gsub("//.*$", "/")
    end
    require("telescope").extensions.file_browser.file_browser({
        hide_parent_dir = true,
        create_from_prompt = true,
        previewer = false,
        no_ignore = true,
        hidden = true,
        quiet = true,
        cwd = pph
    })
end

M.get_word = function()
    builtin.grep_string({ search = vim.fn.expand("<cword>") })
end

return M
