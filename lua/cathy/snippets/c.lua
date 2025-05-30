local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
-- local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
-- local l = extras.lambda
local rep = extras.rep
-- local p = extras.partial
-- local m = extras.match
-- local n = extras.nonempty
-- local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local conds = require("luasnip.extras.expand_conditions")
-- local postfix = require("luasnip.extras.postfix").postfix
-- local types = require("luasnip.util.types")
-- local parse = require("luasnip.util.parser").parse_snippet
-- local ms = ls.multi_snippet
-- local k = require("luasnip.nodes.key_indexer").new_key

local function type_snippet(short, long)
    return s({ trig = short, snippetType = "autosnippet" }, t(long))
end

return {
    s({ trig = "#\"", snippetType = "autosnippet" }, fmt([[
    #include "{file}"
    ]], {
        file = i(1, "file")
    })),

    s({ trig = "#<", snippetType = "autosnippet" }, fmt([[
    #include <{file}>
    ]], {
        file = i(1, "file")
    })),

    type_snippet("u8", "uint8_t"),
    type_snippet("u16", "uint16_t"),
    type_snippet("u32", "uint32_t"),
    type_snippet("u64", "uint64_t"),

    type_snippet("i8", "int8_t"),
    type_snippet("i16", "int16_t"),
    type_snippet("i32", "int32_t"),
    type_snippet("i64", "int64_t"),
}
