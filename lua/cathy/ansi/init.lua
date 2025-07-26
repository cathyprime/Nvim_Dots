local M = {}

local H = {
    patterns = require("cathy.ansi.patterns")
}

function H.chop_till(self, pos)
    return string.sub(self, 1, pos - 1), string.sub(self, pos, -1)
end

function H.parse_line(line)
    local positions = setmetatable({}, {
        __index = function (tbl, key)
            local got = rawget(tbl, key)
            if not got then
                got = {}
                rawset(tbl, key, got)
            end
            return got
        end
    })

    while true do
        local split_position = H.patterns.scanner:match(line)
        local removed_chunk, rest = H.chop_till(line, split_position)

        local chop = H.patterns.ansi_normal_split:match(removed_chunk)
        if not chop or chop == #line then
            break
        end

        local normal, ansi = H.chop_till(removed_chunk, chop)
        if normal ~= "" then
            line = normal .. rest
        else
            line = rest
        end

        ansi = H.patterns.ansi_parse:match(ansi)
        if ansi.cmd == "m" then
            table.insert(positions[chop], ansi.values)
        end
    end

    local trans_pos = {}
    local keys = vim.tbl_keys(positions)
    table.sort(keys)

    for _, key in ipairs(keys) do
        table.insert(trans_pos, {
            pos = key,
            values = positions[key]
        })
    end

    return line, trans_pos
end

local ns = vim.api.nvim_create_namespace("Magda_Ansi_Codes")
function M.colorize_line(bufnr, linenr)
    linenr = linenr - 1
    local line = vim.api.nvim_buf_get_lines(bufnr, linenr, linenr + 1, false)[1]

    local line, positions = H.parse_line(line)
    vim.api.nvim_buf_set_lines(bufnr, linenr, linenr + 1, false, { line })
    require("cathy.ansi.utils")
        .parse_codes(positions)
        :apply(0, linenr)
end

function M.strip_line(line)
    local stripped, positions = H.parse_line(line)
    local ranges = require("cathy.ansi.utils")
        .parse_codes(positions)
    local color_func = function (bufnr, linenr)
        ranges:apply(bufnr, linenr)
    end
    return stripped, color_func
end

function M.strip_lines(lines)
    local stripped_lines = {}
    local range_tbl = {}
    for _, line in ipairs(lines) do
        if M.has_ansi_code(line) then
            local stripped_line, positions = H.parse_line(line)
            local ranges = require("cathy.ansi.utils").parse_codes(positions)

            table.insert(stripped_lines, stripped_line)
            table.insert(range_tbl, ranges)
        else
            table.insert(stripped_lines, line)
            table.insert(range_tbl, 0)
        end
    end
    local coloring = function(bufnr, linenr)
        for _, ranges in ipairs(range_tbl) do
            if type(ranges) ~= "number" then
                ranges:apply(bufnr, linenr)
            end
            linenr = linenr + 1
        end
    end
    return stripped_lines, coloring
end

function M.has_ansi_code(line)
    if type(line) == "string" then
        return H.patterns.has_ansi:match(line) and true or false
    end
    local lines = line
    return vim.iter(lines):any(function (line)
        return H.patterns.has_ansi:match(line)
    end)
end

return M
