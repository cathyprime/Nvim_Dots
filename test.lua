local Buf = {}

local function set_lines(buffer, start, end_, replacement)
    replacement.plain = nil
    vim.bo[buffer].modifiable = true
    vim.api.nvim_buf_set_lines(buffer, start, end_, false, replacement)
    vim.bo[buffer].modifiable = false
    vim.bo[buffer].modified = false
end

local function normalize_lines(lines)
    if type(lines) == "string" then
        lines = vim.split(lines, "\n", { plain = true, trimempty = false })
        lines.plain = true
    end
    return lines
end

local function obj_guard(buf_obj)
    return buf_obj.bufid == nil
end

function Buf:lines(start, end_)
    vim.validate("start", start, "number", true)
    vim.validate("end_", end_, "number", true)
    if obj_guard(self) then return end
    if start == nil then
        start = 0
    end
    if end_ == nil then
        end_ = -1
    end
    return vim.api.nvim_buf_get_lines(self.bufid, start, end_, false)
end

function Buf:append(lines)
    vim.validate("lines", lines, { "table", "string" })
    if obj_guard(self) then return end
    set_lines(self.bufid, -1, -1, normalize_lines(lines))
end

function Buf:replace(start, lines)
    vim.validate("start", start, "number")
    vim.validate("lines", lines, { "table", "string" })
    if obj_guard(self) then return end
    lines = normalize_lines(lines)
    set_lines(self.bufid, start, start + #lines, lines)
end

function Buf:delete()
    if obj_guard(self) then return end
    vim.api.nvim_buf_delete(self.bufid, { force = true })
    self.bufid = nil
end

function Buf:register_keymap(mode, lhs, rhs, opts)
    vim.validate("mode", mode, "string")
    vim.validate("lhs", lhs, "string")
    vim.validate("rhs", rhs, { "string", "function" })
    vim.validate("opts", opts, "table", true)
    if obj_guard(self) then return end

    opts = opts or {}
    opts.buffer = self.bufid

    vim.keymap.set(mode, lhs, rhs, opts)
end

function Buf.new()
    local obj = setmetatable({}, { __index = Buf })
    obj.bufid = vim.api.nvim_create_buf(true, false)
    vim.bo[obj.bufid].modifiable = false

    return obj
end

local buf = Buf.new()
local window = vim.api.nvim_open_win(buf.bufid, false, {
    split = "below",
    win = 0
})

buf:register_keymap("n", "q", function ()
    vim.api.nvim_win_close(window, false)
    buf:delete()
end)

buf:replace(0, {
    plain = true,
    string.format("-*- Compilation_Mode; Starting_Directory :: %s -*-", vim.uv.cwd():gsub(os.getenv "HOME", "~")),
    "Compilation started at "..os.date "%a %b %d %H:%M:%S"
})

buf:append({ "hello", "world" })
buf:append({ "hello", "world" })
buf:replace(4, { "goodbye", "mars" })
