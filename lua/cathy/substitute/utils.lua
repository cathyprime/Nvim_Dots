---@class Str_Opts
---@field uppercase boolean
---@field lowercase boolean
---@field underscore boolean
---@field dash boolean
---@field dot boolean
---@field slash boolean
---@field space boolean

---@param str string
---@return Str_Opts
local str_to_opts = function (str)
    return {
        uppercase  = str:match "[A-Z]" ~= nil,
        lowercase  = str:match "[a-z]" ~= nil,
        underscore = str:match "_" ~= nil,
        dash       = str:match "-" ~= nil,
        dot        = str:match "%." ~= nil,
        slash      = str:match "/" ~= nil,
        space      = str:match " " ~= nil,
    }
end

local starts_capital = function (str)
    return str:match "^[A-Z]" ~= nil
end

local starts_small = function (str)
    return str:match "^[a-z]" ~= nil
end

local all_words_with_capital = function (sep)
    return function (str)
        return str:match(sep .. "[a-z]") == nil
    end
end

local case = {
    ada = {
        "lowercase", "uppercase", "underscore",
        starts_capital, all_words_with_capital("_")
    },
    camel = {
        "lowercase", "uppercase", starts_small
    },
    dot = {
        "lowercase", "uppercase", "dot",
    },
    kebab = {
        "dash", "lowercase"
    },
    pascal = {
        "lowercase", "uppercase", starts_capital
    },
    path = {
        "lowercase", "slash",
    },
    screaming_snake = {
        "uppercase", "underscore"
    },
    snake = {
        "lowercase", "underscore"
    },
    space = {
        "lowercase", "space",
    },
    title = {
        "uppercase", "lowercase", starts_capital, all_words_with_capital("-")
    }
}
