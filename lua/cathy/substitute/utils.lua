local str_to_opts = function (str)
    return {
        uppercase  = str:match "[A-Z]" ~= nil,
        lowercase  = str:match "[a-z]" ~= nil,
        underscore = str:match "_"     ~= nil,
        dash       = str:match "-"     ~= nil,
        dot        = str:match "%."    ~= nil,
        slash      = str:match "/"     ~= nil,
        space      = str:match " "     ~= nil,
    }
end

local tbl_partition = function (tbl, pred)
    local p1 = {}
    local p2 = {}

    for key, value in pairs(tbl) do
        if (pred(key)) then
            p1[key] = value
        else
            p2[key] = value
        end
    end

    return p1, p2
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

local first_upper = function (it)
    return (it:gsub("^%l", string.upper))
end

local split_capitals = function (str)
    str = str:gsub("([A-Z])", " %1")
    str = str:gsub("^%s+", "")
    return vim.iter(str:gmatch("%S+")):fold({}, function (acc, it)
        table.insert(acc, it)
        return acc
    end)
end

local simple_split_gen = function (sep)
    return function (str)
        return vim.split(str, sep, { plain = true, trimempty = false })
    end
end

local simple_join_gen = function (sep)
    return function (parts)
        return table.concat(parts, sep)
    end
end

local modifier_split_gen = function (split, mod)
    return function (str)
        return vim.iter(split(str)):map(mod):totable()
    end
end

local modifier_join_gen = function (join, mod)
    return function (parts)
        return join(vim.iter(parts):map(mod):totable())
    end
end

local case = {
    ada = {
        rules = {
            "lowercase", "uppercase", "underscore",
            starts_capital, all_words_with_capital "_",
        },
        to = modifier_join_gen(simple_join_gen "_", first_upper),
        from = modifier_split_gen(simple_split_gen "_", string.lower)
    },
    camel = {
        rules = {
            "lowercase", "uppercase", starts_small
        },
        to = function (parts)
            local t = vim.iter(parts):skip(1):map(first_upper):totable()
            table.insert(t, 1, parts[1])
            return table.concat(t)
        end,
        from = modifier_split_gen(split_capitals, string.lower)
    },
    dot = {
        rules = {
            "lowercase", "dot",
        },
        to = simple_join_gen ".",
        from = simple_split_gen "."
    },
    kebab = {
        rules = {
            "dash", "lowercase"
        },
        to = simple_join_gen "-",
        from = simple_split_gen "-"
    },
    pascal = {
        rules = {
            "lowercase", "uppercase", starts_capital,
        },
        to = modifier_join_gen(simple_join_gen(), first_upper),
        from = modifier_split_gen(split_capitals, string.lower)
    },
    path = {
        rules = {
            "lowercase", "slash",
        },
        to = simple_join_gen "/",
        from = simple_split_gen "/"
    },
    screaming_snake = {
        rules = {
            "uppercase", "underscore"
        },
        to = modifier_join_gen(simple_join_gen "_", string.upper),
        from = modifier_split_gen(simple_split_gen "_", string.lower)
    },
    snake = {
        rules = {
            "lowercase", "underscore"
        },
        to = simple_join_gen "_",
        from = simple_split_gen "_"
    },
    space = {
        rules = {
            "lowercase", "space",
        },
        to = simple_join_gen " ",
        from = simple_split_gen " "
    },
    title = {
        rules = {
            "uppercase", "lowercase", "dash",
            starts_capital, all_words_with_capital "-"
        },
        to = modifier_join_gen(simple_join_gen "-", first_upper),
        from = modifier_split_gen(simple_split_gen "-", string.lower)
    },
}

local case_of = function (str)
    local str_opts = str_to_opts(str)
    for case, v in pairs(case) do
        local names = vim.iter(v.rules)
            :filter(function (v) return type(v) == "string" end)
            :totable()
        local funcs = vim.iter(v.rules)
            :filter(function (v) return type(v) == "function" end)

        local must, must_not = tbl_partition(str_opts, function (it) return vim.tbl_contains(names, it) end)

        local must_satisfied = vim.iter(must):all(function (_, value) return value end)
        local must_not_satisfied = vim.iter(must_not):all(function (_, value) return not value end)
        local funcs_satisfied = true
        if funcs:peek() ~= nil then
            funcs_satisfied = funcs:all(function (f) return f(str) end)
        end

        if must_satisfied and must_not_satisfied and funcs_satisfied then
            return case
        end
    end

    return nil
end

local split = function (str)
    local caseof = case_of(str)
    if caseof == nil then
        local _, n = str:gsub("%S+","")
        if n == 1 then
            return { str }
        end
        return nil
    end
    return case[caseof].from(str)
end

local permutations = function (str)
    local parts = split(str)

    local make_pattern = function (_, tbl)
        return tbl.to(parts)
    end

    local seen = {}
    local uniq = function (acc, it)
        if not seen[it] then
            seen[it] = true
            table.insert(acc, it)
        end
        return acc
    end

    return vim.iter(pairs(case)):map(make_pattern):fold({}, uniq)
end

return {
    space_split = case.space.from,
    caseof = case_of,
    permutations = permutations,
    str_to_parts = function (str, str_case)
        return case[str_case].from(str)
    end,
    convert = function (str, str_case)
        return case[str_case].to(split(str))
    end,
    parts_to_str = function (parts)
        local str_case = case_of(parts)
        if str_case == nil then
            return nil
        end
        return case[str_case].to(parts)
    end,
    make_regex = function (str)
        return string.format([[\C\(%s\)]], table.concat(permutations(str), [[\|]]))
    end
}
