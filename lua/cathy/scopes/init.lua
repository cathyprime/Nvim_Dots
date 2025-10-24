local utils = require("cathy.scopes.utils")

local H = {}
local M = {}

local git_cache = {}
local function is_git_root(dir)
    if git_cache[dir] == nil then
        git_cache[dir] = (vim.uv or vim.loop).fs_stat(dir .. "/.git") ~= nil
    end
    return git_cache[dir]
end

function H.git_root(path)
    path = path or 0
    path = type(path) == "number" and vim.api.nvim_buf_get_name(path) or path
    path = path == "" and vim.uv.cwd() or path
    path = vim.fs.normalize(path)

    if is_git_root(path) then
        return path
    end

    for dir in vim.fs.parents(path) do
        if is_git_root(dir) then
            return vim.fs.normalize(dir)
        end
    end

    return os.getenv("GIT_WORK_TREE")
end

function H.get_root()
    local buf_path = require("cathy.utils").cur_buffer_path()
    local git_root = H.git_root(buf_path)
    return git_root and git_root or buf_path
end

function M.get_root()
    local cwd = H.get_root()
    return utils.Scopes[cwd]:get_path(require("cathy.utils").cur_buffer_path())
end

function M.edit_scopes()
    local cwd = H.get_root()
    local repo = utils.Scopes[cwd]
    local bufnr = repo:make_buf()
    utils.open_window(bufnr, "Scopes :: " .. cwd, 0.4)
    vim.cmd.lcd(cwd)
end

return M
