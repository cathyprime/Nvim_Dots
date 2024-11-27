local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
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

return {

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

    s("timeout", fmt([[
    setTimeout(({args}) => {{
        {body}
    }}, {time})
    ]], {
        args = i(1),
        time = i(2, "time"),
        body = i(0)
    })),

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
                t") =>",
            }),
            sn(nil, {
                t"function ",
                i(1, "name"),
                t"(",
                i(2),
                t")"
            }),
            sn(nil, {
                c(1, {
                    t"const ",
                    t"let ",
                }),
                i(2, "name"),
                t" = function(",
                i(3),
                t")"
            }),
        }),
        body = i(0)
    })),

    s("p", fmt([[
    console.log({val});
    ]], {
        val = i(0)
    })),

    s("var", fmt([[
    {type} {name}{value};
    ]], {
        type = c(1, {
            t"const",
            t"let",
        }),
        name = i(2, "name"),
        value = c(3, {
            sn(nil, {
                t" = ",
                i(1, "value")
            }),
            t"",
        })
    })),

    s("()", fmt([[
    ({}) => {{{}}}
    ]], {
        i(1),
        i(0)
    })),

    s("req", fmt([[
    const {name} = require("{module}");
    ]], {
        name = f(function (import_name)
            local parts = vim.split(import_name[1][1], "%/")
            if parts[#parts] == "lodash" then
                return "_"
            else
                return parts[#parts] or "name"
            end
        end, { 1 }),
        module = i(1, "module")
    })),

    s("init", fmt([[
    constructor({args}) {{
        {assign}{body}
    }}
    ]], {
        args = i(1),
        assign = d(2, function (args)
            local args_str = args[1][1]
            args_str = args_str:gsub(', ', ',')
            if args_str == "" then
                return sn(nil, {t("")})
            end
            local nodes = vim.iter(vim.split(args_str, ',')):fold({}, function(acc, arg)
                table.insert(acc, "this." .. arg .. " = " .. arg .. ";")
                return acc
            end)
            return isn(nil, t(nodes), "$PARENT_INDENT\t")
        end, { 1 }),
        body = i(0)
    })),

    s("m", fmt([[
    {name}({args}) {{
        {body}
    }}
    ]], {
        name = i(1, "name"),
        args = i(2),
        body = i(0)
    })),
}
