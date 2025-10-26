local Buf = {}

local function set_lines(buffer, start, end_, replacement)
    vim.bo[buffer].modifiable = true
    vim.api.nvim_buf_set_lines(buffer, start, end_, false, replacement)
    vim.bo[buffer].modifiable = false
    vim.bo[buffer].modified = false
end

local function normalize_lines(lines)
    if type(lines) == "string" then
        lines = vim.split(lines, "\n", { plain = true, trimempty = false })
    end
    return lines
end

local function obj_guard(buf_obj)
    return buf_obj.bufid == nil or not vim.api.nvim_buf_is_valid(buf_obj.bufid)
end

function Buf:append_data(data)
    vim.validate("data", data, "string")
    if obj_guard(self) then return end

    local buf = self.bufid

    local line_count = vim.api.nvim_buf_line_count(buf)

    if line_count == 0 then
        vim.api.nvim_buf_set_lines(buf, 0, 0, false, {""})
        line_count = 1
    end

    vim.bo[buf].modifiable = true

    local parts = vim.split(data, "\n", { plain = true, trimempty = false })
    if not self._ends_with_newline then
        local last_line_index = line_count - 1
        local last_line = vim.api.nvim_buf_get_lines(buf, last_line_index, last_line_index + 1, false)[1] or ""
        local new_first = last_line .. parts[1]
        vim.api.nvim_buf_set_lines(buf, last_line_index, last_line_index + 1, false, { new_first })
        table.remove(parts, 1)
    end

    if #parts > 0 then
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, parts)
    end

    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false

    self._ends_with_newline = vim.endswith(data, "\n")
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

function Buf:append_lines(lines)
    vim.validate("lines", lines, { "table", "string" })
    if obj_guard(self) then return end
    set_lines(self.bufid, -1, -1, normalize_lines(lines))
    self._ends_with_newline = true
end

function Buf:replace_lines(...)
    local start
    local end_
    local lines
    if select("#", ...) == 2 then
        vim.validate("start", select(1, ...), "number")
        vim.validate("lines", select(2, ...), { "table", "string" })
        start, lines = select(1, ...)
    else
        vim.validate("start", select(1, ...), "number")
        vim.validate("end",   select(2, ...), "number")
        vim.validate("lines", select(3, ...), { "table", "string" })
        start, end_, lines = select(1, ...)
    end
    if obj_guard(self) then return end
    lines = normalize_lines(lines)
    if end_ then
        set_lines(self.bufid, start, end_, lines)
    else
        set_lines(self.bufid, start, start + #lines, lines)
    end
    self._ends_with_newline = true
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
    obj._ends_with_newline = false
    obj.bufid = vim.api.nvim_create_buf(true, false)
    vim.bo[obj.bufid].modifiable = false

    return obj
end

return Buf
