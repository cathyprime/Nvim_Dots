local M = {}

local H = {}

function M.open_window(bufnr, name, size)
    size = size or 0.70

    local columns = vim.opt.columns:get()
    local lines = vim.opt.lines:get()
    local i_size = (1 - size) / 2

    local height = math.floor(lines   * size)
    local width  = math.floor(columns * size)
    local row    = math.floor(lines   * i_size)
    local col    = math.floor(columns * i_size)

    vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "single",
        title = name,
        title_pos = "center"
    })
end

---@class Scope
---@field file File
---@field paths? table<string>
local Scope = {}
function Scope:save()
    if self.paths then
        for i, path in ipairs(self.paths) do
            if path:sub(-1) ~= "/" then
                self.paths[i] = path .. "/"
            end
        end
        self.file:save(self.paths)
    end
end

function Scope:load(force)
    if not self.paths or force == true then
        self.paths = self.file:read()
    end
end

function Scope:get_path(buf_path)
    local git_root = self.file.git_root
    if not self.paths then
        return git_root
    end

    for _, path in ipairs(self.paths) do
        local sub_path = vim.fs.normalize(git_root .. path)
        if buf_path:find(sub_path) ~= nil then
            return sub_path
        end
    end
    return git_root
end

function H.make_buf()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].ft = "text"
    return bufnr
end

function H.set_maps(bufnr, scope)
    local close_buf = function ()
        local ok, _ = pcall(vim.cmd.close)
        if not ok then
            vim.cmd.bdelete()
        end
    end
    vim.keymap.set("n", "q", close_buf, {
        buffer = bufnr,
        silent = true,
        noremap = true,
        nowait = true
    })
end

function Scope:make_buf()
    local bufnr = H.make_buf()
    H.set_maps(bufnr, self)
    if self.paths then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, self.paths)
    end
    vim.api.nvim_create_autocmd({ "BufDelete", "BufHidden" }, {
        buffer = bufnr,
        once = true,
        callback = function ()
            self.paths = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
            self:save()
        end
    })
    return bufnr
end

---@class Scopes: table<string, Scope>
local Scopes = {}
function Scopes.__index(self, path)
    if not rawget(self, path) then
        local obj = setmetatable({}, { __index = Scope })
        obj.file = require("cathy.scopes.fs").file(path)
        obj:load()
        rawset(self, path, obj)
    end
    return rawget(self, path)
end

M.Scopes = setmetatable({}, Scopes)

return M
