local M = {}
local H = {}

local opt = function (opt, state)
    return function (opts)
        opts[opt] = state
        return opts
    end
end

H.types = {
    fg = {},
    bg = {},
    all = {},
    prop = {}
}

local properties = {
    bold = { 1, 22 },
    italic = { 3, 23 },
    underline = { 4, 24 },
    reverse = { 7, 27 },
    strikethrough = { 9, 29 },
    underdouble = { 21, 24 },
}

H.codes = {
    [0] = { type = H.types.all },
}

for name, codes in pairs(properties) do
    H.codes[codes[1]] = { type = H.types.prop, prop_type = properties[name], set_opts = opt(name, true) }
    H.codes[codes[2]] = { type = H.types.prop, prop_type = properties[name], set_opts = opt(name, false) }
end

for i = 30, 37 do H.codes[i] = { type = H.types.fg } end
for i = 90, 97 do H.codes[i] = { type = H.types.fg } end
for i = 40, 47 do H.codes[i] = { type = H.types.bg } end
for i = 100, 107 do H.codes[i] = { type = H.types.bg } end

vim.print(H.codes)

return M
