---@class File
---@field filename string
---@field git_root string
local File = {}

function File:save(contents)
    local dir = vim.fn.fnamemodify(self.filename, ":p:h")
    if not vim.uv.fs_stat(dir) then
        vim.fn.mkdir(dir, "p")
    end

    local data = table.concat(contents, '\n')
    local file = io.open(self.filename, "w")

    file:write(data)
    file:close()
end

function File:read()
    local file = io.open(self.filename, 'r')
    if not file then
        return nil
    end
    local content = file:read("*a")
    return vim.split(content, '\n', { plain = true, trimempty = true })
end

local M = {}

function M.file(root)
    local scopes_dir = vim.fn.stdpath("data") .. "/scopes/"
    local filename = scopes_dir .. (root:gsub("/", [[_]])) .. ".scopes"
    if root:sub(-1) ~= "/" then
        root = root .. "/"
    end
    return setmetatable({ filename = filename, git_root = root }, { __index = File })
end

return M
