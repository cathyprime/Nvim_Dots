local ls = require("luasnip")
local gen = require("cathy.sniper")
local utils = require("cathy.sniper.utils")
local s = ls.snippet
local sn = ls.snippet_node
local f = ls.function_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
-- local tsp = require("luasnip.extras.treesitter_postfix").treesitter_postfix

local auto_snip = function (trig)
    return { trig = trig, snippetType = "autosnippet" }
end

return {
    s(auto_snip"!beg", fmta([[
    \begin{<word>}
    \end{<>}
    ]], {
        word = i(1),
        rep(1)
    })),

    s(auto_snip"!list", fmta([[
    \begin{itemize}
        \item <item>
    \end{itemize}
    ]], {
        item = i(0)
    })),

    s(auto_snip"!enum", fmta([[
    \begin{enumerate}
        \item <item>
    \end{enumerate}
    ]], {
        item = i(0)
    })),
}
