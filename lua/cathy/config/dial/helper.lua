local augend = require("dial.augend")

local function words(elements, word, cyclic, case)
    if word == nil then
        word = true
    end
    if cyclic == nil then
        cyclic = true
    end
    if case == nil then
        case = true
    end
    return augend.constant.new({
        elements = elements,
        word = word,
        cyclic = cyclic,
        preserve_case = case
    })
end

local function extend(t)
    local defaults = {
        augend.integer.alias.binary,
        augend.integer.alias.decimal_int,
        augend.integer.alias.hex,
        augend.date.alias["%d/%m/%Y"],
        words({ "&&", "||" }, false, true),
        words({ "and", "or" }),
        words({ "true", "false" }),
        augend.decimal_fraction.new({
            signed = true,
            point_char = ".",
        }),
        augend.constant.alias.Alpha,
    }
    for _, v in ipairs(t or {}) do
        table.insert(defaults, v)
    end
    return defaults
end

return {
    register_group = {
        default = extend({
            words({ "private", "protected", "public" }, nil, false),
        }),
        case = {
            augend.case.new({
                types = {
                    "camelCase",
                    "PascalCase",
                    "kebab-case",
                    "snake_case",
                    "SCREAMING_SNAKE_CASE",
                },
                cyclic = true,
            }),
        },
    },
    on_filetype = {
        rust = extend({
            words({ "self", "super", "crate" }, nil, false),
        }),
        cs = extend({
            words({"sealed", "private", "protected", "internal", "public"}, nil, false),
            words({"abstract", "virtual"}),
        }),
        java = extend({
            words({"default", "private", "protected", "public"}, nil, false),
        }),
    }
}
