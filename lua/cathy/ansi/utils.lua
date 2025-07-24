local ansi_codes = require("cathy.ansi.codes")

local tbl = {
    {
        pos = 4,
        values = { { 36 }, { 1 } }
    },
    {
        pos = 9,
        values = { { 39 }, { 22 } }
    },
    {
        pos = 11,
        values = { { 36 }, { 1 } }
    },
    {
        pos = 12,
        values = { { 39 }, { 22 } }
    }
}

local Hl_Opts = {}
setmetatable(Hl_Opts, {
    __index = ansi_codes
})

function Hl_Opts:apply_codes(codes)
    for _, code in ipairs(codes) do
        self[code](self)
    end
end

function Hl_Opts.new(tbl)
    return setmetatable(tbl or {}, {
        __index = Hl_Opts,
        __sub = Hl_Opts.__sub
    })
end

function Hl_Opts.__sub(new, old)
    old = old or {}
    local diff = {}
    for k, v in pairs(new) do
        if old[k] ~= v then
            diff[k] = v
        end
    end
    for k, v in pairs(old) do
        if new[k] == nil then
            diff[k] = nil
        end
    end
    return Hl_Opts.new(diff)
end

local hl_opts = Hl_Opts.new()

local ranges = {}

local previous_position = 0
local previous_opts = Hl_Opts.new()

for _, codes in ipairs(tbl) do
    hl_opts, previous_opts = previous_opts, hl_opts
    hl_opts:apply_codes(codes.values)

    local diff = previous_opts - hl_opts
    if #vim.tbl_keys(diff) ~= 0 then
        table.insert(ranges, {
            start = previous_position,
            finish = codes.pos,
            hl_opts = setmetatable(diff, nil)
        })
    end

    previous_position = codes.pos
end

vim.print(ranges)
