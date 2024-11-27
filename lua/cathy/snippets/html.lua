local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
-- local d = ls.dynamic_node
local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
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

local rep_first = function(args)
    args = args or {"", ""}
    local first = vim.split(args[1][1], " ")
    return first[1] or args[1][1]
end

local tag =
[[<{name}>
    {body}
</{repeatname}>]]

local oneliner = [[<{name}>{body}</{repeatname}>]]

local function css(trig)
end

return {
    s("html", fmt([[
    <!DOCTYPE html>
    <html lang="{lang}">
        <head>
            <meta charset="{charset}">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>{title}</title>
        </head>
        <body>
            {body}
        </body>
    </html>
    ]], {
        lang = i(1, "en"),
        charset = i(2, "utf-8"),
        title = i(3, "title"),
        body = i(0)
    })),

    s("css", fmt([[<link rel="stylesheet" href="{stylesheet}.css">]], {
        stylesheet = i(1, "styles")
    })),

    s("js", fmt([[<script src="{stylesheet}.js"></script>]], {
        stylesheet = i(1, "index")
    })),

    s("tag", fmt([[{}]], {
        c(1, {
            sn(nil, fmt(tag, {
                name = r(1, "name"),
                body = i(2),
                repeatname = f(rep_first, {1}),
            })),
            sn(nil, fmt([[<{name}/>]], { name = r(1, "name") }))
        }),
    }), {
        stored = {
            name = i(1, "")
        }
    }),

    s("t", fmt([[{}]], {
        c(1, {
            sn(nil, fmt(oneliner, {
                name = r(1, "name"),
                body = i(2),
                repeatname = f(rep_first, {1}),
            })),
            sn(nil, fmt([[<{name}/>]], { name = r(1, "name") }))
        })
    }), {
        stored = {
            name = i(1, "")
        }
    }),
}
