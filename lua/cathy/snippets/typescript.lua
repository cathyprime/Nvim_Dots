local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
-- local f = ls.function_node
local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- local ai = require("luasnip.nodes.absolute_indexer")
-- local extras = require("luasnip.extras")
-- local l = extras.lambda
-- local rep = extras.rep
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

return {
    s("fn", fmt([[
    {fn} {{
        {body}
    }}
    ]], {
        fn = c(1, {
            sn(nil, {
                c(1, {
                    t"const ",
                    t"let ",
                }),
                i(2, "name"),
                t" = (",
                i(3),
                t"): ",
                i(4, "retType"),
                t" =>"
            }),
            sn(nil, {
                t"function ",
                i(1, "name"),
                t"(",
                i(2),
                t"): ",
                i(3, "retType")
            }),
            sn(nil, {
                c(1, {
                    t"const ",
                    t"let ",
                }),
                i(2, "name"),
                t" = function(",
                i(3),
                t"): ",
                i(4, "retType")
            }),
        }),
        body = i(0)
    })),
}
