local ok, _ = pcall(require, "telescope")
if not ok then
    local empty = function()
        vim.notify("failed to load telescope, try restarting neovim Kappa", vim.log.levels.ERROR)
    end
    return {
        project_files = empty,
        change_dir = empty,
        multi_grep = empty,
        get_nvim = empty,
        get_word = empty,
        hidden = empty,
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

M.multi_grep = function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd or vim.uv.cwd()
    local finder = require("telescope.finders").new_async_job {
        command_generator = function(prompt)

            if not prompt or promot == "" then
                return
            end

            local pieces = vim.split(prompt, "  ")
            local args = { "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" }
            if pieces[1] then
                table.insert(args, "-e")
                table.insert(args, pieces[1])
            end

            if pieces[2] then
                table.insert(args, "-g")
                table.insert(args, pieces[2])
            end

            return args
        end,
        entry_maker = require("telescope.make_entry").gen_from_vimgrep(opts),
        cwd = opts.cwd,
    }

    require("telescope.pickers").new(opts, {
        debounce = 100,
        prompt_title = "Grep (multi)",
        finder = finder,
        previewer = require("telescope.config").values.grep_previewer(opts),
        sorter = require("telescope.sorters").empty(),
    }):find()
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
