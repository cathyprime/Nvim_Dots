local opt = function (arr)
    return function (opts)
        for key, value in pairs(arr) do
            if value == false then
                opts[key] = nil
                goto continue
            end
            opts[key] = value
            ::continue::
        end
    end
end

local function reset(opts)
    for key, _ in pairs(opts) do
        opts.key = false
    end
    opts.fg = nil
    opts.bg = nil
end

local function reset_color(key)
    return function (opts)
        opts[key] = nil
    end
end

local codes = {
    [0] = reset,

    [1]  = opt { bold = true },
    [22] = opt { bold = false },

    [3]  = opt { italic = true },
    [23] = opt { italic = false },

    [4]  = opt { underline = true },
    [24] = opt { underline = false, underdouble = false },

    [7]  = opt { reverse = true },
    [27] = opt { reverse = false },

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

local function to_hex(code1, code2, code3)
    if code2 == nil and code3 == nil then
        return "#"
            .. string.format("%02x", code1)
            .. string.format("%02x", code1)
            .. string.format("%02x", code1)
    end
    return "#"
        .. string.format("%02x", code1)
        .. string.format("%02x", code2)
        .. string.format("%02x", code3)
end

local function to_idx(code)
    local foreground_range = 30 <= code and code <= 38
    local background_range = 40 <= code and code <= 48
    local bright_foreground_range = 90 <= code and code <= 97
    local bright_background_range = 100 <= code and code <= 107

    return code == foreground_range and code - 30
        or code == background_range and code - 30
end

local function ansi_cube (ansi16, code)
    if code <= 16 then
        return ansi16[code]
    end
    if code >= 232 then
        local gray = code - 232
        local level = gray * 10 + 8
        return to_hex(level)
    end

    code = code - 16
    local red = math.floor(code / 36)
    local green = math.floor(code / 6) % 6
    local blue = code % 6

    local level = function (value)
        return value == 0 and 0
            or 55 + value * 40
    end

    return to_hex(level(red), level(green), level(blue))
end

local function calc_field(code)
    local foreground_range = 30 <= code and code <= 37
    local background_range = 40 <= code and code <= 47
    local bright_foreground_range = 90 <= code and code <= 97
    local bright_background_range = 100 <= code and code <= 107
    local is_bright = bright_foreground_range or bright_background_range

    if is_bright then
        code = code - 60
    end

    if foreground_range or bright_foreground_range then
        return "fg"
    end
    return "bg"
end

local function ansi_to_hex(ansi_code)
    local ansi16 = setmetatable({
        "#000000", "#cd0000", "#00cd00", "#cdcd00",
        "#0000ee", "#cd00cd", "#00cdcd", "#e5e5e5",
        "#7f7f7f", "#ff0000", "#00ff00", "#ffff00",
        "#5c5cff", "#ff00ff", "#00ffff", "#ffffff",
    }, {
        __index = function (self, code)
            local foreground_range = 30 <= code and code <= 37
            local background_range = 40 <= code and code <= 47
            local bright_foreground_range = 90 <= code and code <= 97
            local bright_background_range = 100 <= code and code <= 107
            local is_bright = bright_foreground_range or bright_background_range

            if foreground_range or bright_foreground_range then
                local idx = (is_bright and code - 60 or code) - 29
                local field = "fg"
                return self[idx], field
            end
            if background_range or bright_background_range then
                local idx = (is_bright and code - 60 or code) - 39 + 8
                local field = "bg"
                return self[idx], field
            end
            error("Bad index")
        end
    })

    if ansi_code[1] == 38 or ansi_code[1] == 48 then
        local field = ansi_code[1] == 38 and "fg" or "bg"

        if ansi_code[2] == 2 then
            value = to_hex(ansi_code[3], ansi_code[4], ansi_code[5])
        end

        if ansi_code[2] == 5 then
            value = ansi_cube(ansi16, ansi_code[3])
        end

        return function (opts)
            opts[field] = value
        end
    end

    local value = ansi16[ansi_code[1]]
    local field = calc_field(ansi_code[1])
    return function (opts)
        opts[field] = value
    end
end

local function fallback(self, ansi_code)
    if type(ansi_code) ~= "table" and type(ansi_code) ~= "number" then
        return
    end
    assert(type(ansi_code) == "table" or type(ansi_code) == "number",
           "Index with table only!")

    local code = type(ansi_code) == "table" and ansi_code[1] or ansi_code
    assert(validate(code), "Invalid code provided!")

    local func = rawget(codes, code)
    if func then
        return func
    end

    return ansi_to_hex(ansi_code)
end

return setmetatable({}, {
    __index = fallback
})
