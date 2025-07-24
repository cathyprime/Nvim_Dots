local M = {}

local H = {
    patterns = require("cathy.ansi.patterns")
}

function H.chop_till(self, pos)
    return string.sub(self, 1, pos - 1), string.sub(self, pos, -1)
end

local bufnr = 0
local ns = vim.api.nvim_create_namespace("Magda_Ansi_Codes")

local start_line_nr = vim.api.nvim_buf_line_count(bufnr) - 2
local lines = vim.api.nvim_buf_get_lines(bufnr, start_line_nr, start_line_nr + 2, false)

function M.parse_line(line)
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

local line, positions = M.parse_line(lines[1])
vim.print(positions)

-- [36m[1mbuild[39m[22m, [36m[1mb[39m[22m    Compile the current package
-- [36m[1mcheck[39m[22m, [36m[1mc[39m[22m    Analyze the current package and report errors, but don't build object files
