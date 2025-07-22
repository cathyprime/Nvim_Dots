local opt = function (arr)
    return function (opts)
        for key, value in pairs(arr) do
            opts.key = value
        end
        return opts
    end
end

local function reset(opts)
    for key, _ in pairs(opts) do
        opts.key = false
    end
    opts.fg = nil
    opts.bg = nil
    return opts
end

local function reset_color(key)
    return function (opts)
        opts[key] = nil
        return opts
    end
end

-- 30-38
-- 40-48
-- 90-97
-- 100-107

local codes = {
    [0] = reset,

    [1]  = opt { bold = true },
    [22] = opt { bold = false },

    [3]  = opt { italic = true },
    [23] = opt { italic = false },

    [4]  = opt { underline = true },
    [24] = opt { underline = false, underdouble = false },

    [7]  = opt { reverse = true},
    [27] = opt { reverse = false},

    [9]  = opt { strikethrough = true },
    [29] = opt { strikethrough = false },

    [21] = opt { underdouble = true },

    [39] = reset_color "fg",
    [49] = reset_color "bg"
}

local function validate(code)
    if rawget(codes, code) then
        return true
    end
    local foreground_range = 30 <= code and code <= 38
    local background_range = 40 <= code and code <= 48
    local bright_foreground_range = 90 <= code and code <= 97
    local bright_background_range = 100 <= code and code <= 107

    return foreground_range
        or background_range
        or bright_foreground_range
        or bright_background_range
end

local function fallback(tbl, ansi_code)
    assert(type(ansi_code) == "table" or type(ansi_code) == "number",
           "Index with table only!")

    local code = type(ansi_code) == "table" and ansi_code[1] or ansi_code
    assert(validate(code), "Invalid code provided!")

    local func = rawget(codes, code)
    if func then
        return func
    end

    asssert(true, "TODO: create a function to parse code")
end

return setmetatable({}, {
    __index = fallback
})
