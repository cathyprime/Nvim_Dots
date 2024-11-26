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

return {
    s("html5", fmt([[
    <!DOCTYPE html>
    <html lang="{lang}">

        <head>
            <meta charset="{charset}">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>{title}</title>
            <link rel="stylesheet" href="{stylesheet}.css">
        </head>

        <body>
            {body}
        </body>

    </html>
    ]], {
        lang = i(1, "en"),
        charset = i(2, "utf-8"),
        title = i(3, "title"),
        stylesheet = i(4, "styles"),
        body = i(0)
    })),

    s("t", fmt([[<{name}>{body}</{repeatname}>]], {
        name = i(1, "name"),
        repeatname = rep(1),
        body = i(2),
    })),

    s("tag", fmt([[
    <{name}{opts}>
        {body}
    </{repeatname}>
    ]], {
        name = i(1, "name"),
        repeatname = rep(1),
        opts = c(2, {
            t"",
            sn(nil, fmt([[{class}="{name}"]], {
                class = c(1, {
                    t" class",
                    t" id",
                }),
                name = i(2, "name"),
            })),
        }),
        body = i(3),
    }))
}
