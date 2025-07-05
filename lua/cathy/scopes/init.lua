local utils = require("cathy.scopes.utils")

local H = {}
local M = {}

function H.get_root()
    local buf_path = require("cathy.utils").cur_buffer_path()
    local git_root = Snacks.git.get_root(buf_path)
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
