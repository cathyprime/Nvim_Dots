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
-- local extras = require("luasnip.extras")
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
-- local tsp = require("luasnip.extras.treesitter_postfix").treesitter_postfix

local function ranges_views_snippet(trig, func)
    return s(trig,
        fmta([[
		| <namespace>::views::<fn>([&](auto&& value) {
			<body>
		})
      ]], {
        namespace = c(1, {
            t("ranges"),
            t("std"),
        }),
        body = i(0),
        fn = func,
    })
    )
end

local function constructor_snip(trig, name, template)
    return ls.s(
        {
            trig = trig,
            name = ("(%s) %s"):format(trig, name),
            wordTrig = true,
            trigEngine = "plain",
            hidden = true,
            resolveExpandParams = utils.inject_name("CLASS_NAME", {
                "struct_specifier",
                "class_specifier",
            }),
        },
        d(1, function(_, parent)
            local env = parent.env
            return sn(
                nil,
                fmta(template, {
                    cls = t(env.CLASS_NAME),
                })
            )
        end)
    )
end

local expr_query = [[
[
  (call_expression)
  (identifier)
  (template_function)
  (subscript_expression)
  (field_expression)
  (user_defined_literal)
] @prefix
]]

local type = gen.type_surround_gen({
    query = [[
    [
      (qualified_identifier
        name: (type_identifier))
      (type_identifier)
      (primitive_type)
    ] @prefix
    ]],
    query_lang = "cpp",
    select = "longest"
})

local expr_surround = gen.expr_surround_gen({
    query = expr_query,
    query_lang = "cpp",
})

local expr_surround_nodes = gen.expr_surround_gen_with_nodes({
    query = expr_query,
    query_lang = "cpp",
})

return {
    gen.default_qt_snip(gen.quick_type_gen({
        v = { params = 1, template = "std::vector<%s>" },
        a = { params = 1, template = "std::array<%s>" },
        q = { params = 1, template = "std::unique_ptr<%s>" },
        p = { params = 1, template = "std::shared_ptr<%s>" },
        w = { params = 1, template = "std::weak_ptr<%s>" },
        c = { params = 0, template = "Placeholder" },
        i = { params = 0, template = "int32_t" },
        s = { params = 0, template = "std::string" },
        u = { params = 0, template = "uint32_t" },
        m = { params = 2, template = "absl::flat_hash_map<%s, %s>" },
        t = { params = -1, template = "std::tuple<%s>" },
    })),

    type(".up", "std::unique_ptr<%s>"),
    type(".sp", "std::shared_ptr<%s>"),
    type(".wp", "std::weak_ptr<%s>"),
    type(".opt", "std::optional<%s>"),
    type(".vec", "std::vector<%s>"),

    ranges_views_snippet("|trans", t("transform")),
    ranges_views_snippet("|filter", t("filter")),
    ranges_views_snippet("|c", i(2, "func")),

    gen.expand_types("u8", "uint8_t"),
    gen.expand_types("u16", "uint16_t"),
    gen.expand_types("u32", "uint32_t"),
    gen.expand_types("u64", "uint64_t"),

    gen.expand_types("i8", "int8_t"),
    gen.expand_types("i16", "int16_t"),
    gen.expand_types("i32", "int32_t"),
    gen.expand_types("i64", "int64_t"),

    expr_surround(".be", "%s.begin(), %s.end()"),
    expr_surround(".mv", "std::move(%s)"),
    expr_surround(".fwd", "std::forward<decltype(%s)>(%s)"),
    expr_surround(".val", "std::declval<%s>()"),
    expr_surround(".dt", "decltype(%s)"),
    expr_surround(".uu", "(void)%s"),
    expr_surround(".single", "ranges::views::single(%s)"),
    expr_surround(".sizeof", "sizeof(%s) / sizeof(%s[0])"),
    expr_surround_nodes(".sc", fmt("static_cast<{body}>({expr}){end}", {
        body = i(1),
        expr = f(function(_, parent)
            return utils.replace_all(parent.snippet.env.LS_TSMATCH, "%s")
        end, {}),
        ["end"] = i(0),
    })),

    gen.begin_line_snip("#o", { t"#pragma once"} ),
    gen.begin_line_snip("#<", fmt("#include <{}>", { i(1, "file") })),
    gen.begin_line_snip('#"', fmt('#include "{}"', { i(1, "file") })),

    constructor_snip(
        "ctor",
        "Default constructor",
        [[<cls>() = default;]]
    ),
    constructor_snip(
        "dtor",
        "Default destructor",
        [[~<cls>() = default;]]
    ),
    constructor_snip(
        "vdtor",
        "Default destructor",
        [[virtual ~<cls>() = default;]]
    ),
    constructor_snip(
        "cc",
        "Copy constructor",
        [[<cls>(const <cls>& rhs) = default;]]
    ),
    constructor_snip(
        "ca",
        "Copy assigment",
        [[<cls>& operator=(const <cls>& rhs) = default;]]
    ),
    constructor_snip(
        "mc",
        "Move constructor",
        [[<cls>(<cls>&& rhs) = default;]]
    ),
    constructor_snip(
        "ma",
        "Move assigment",
        [[<cls>& operator=(<cls>&& rhs) = default;]]
    ),
    constructor_snip(
        "nca",
        "No copy assigment",
        [[<cls>& operator=(const <cls>& rhs) = delete;]]
    ),
    constructor_snip(
        "nma",
        "No move assigment",
        [[<cls>& operator=(<cls>&& rhs) = delete;]]
    ),
    constructor_snip(
        "ncc",
        "No copy constructor",
        [[<cls>(const <cls>&) = delete;]]
    ),
    constructor_snip(
        "nmc",
        "No move constructor",
        [[<cls>(<cls>&&) = delete;]]
    ),
    constructor_snip(
        "ncm",
        "No copy and move constructor",
        [[
        <cls>(const <cls>&) = delete;
        <cls>(<cls>&&) = delete;
        ]]
    ),
}
