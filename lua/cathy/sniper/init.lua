local utils = require("cathy.sniper.utils")
local ls = require("luasnip")
local tsp = require("luasnip.extras.treesitter_postfix").treesitter_postfix
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node

local function type_snippet(short, long)
    return s({ trig = short, snippetType = "autosnippet" }, t(long))
end

local function type(query)
    return function(trig, replacement)
        return tsp({
            trig = trig .. " ",
            wordTrig = false,
            reparseBuffer = "live",
            snippetType = "autosnippet",
            matchTSNode = query,
        }, {
            f(function(_, parent)
                return utils.replace_all(parent.snippet.env.LS_TSMATCH, replacement .. " ")
            end, {}),
        })
    end
end

local function expr_tsp(query, placeholder)
    return function(trig, expand)
        local name = ("(%s) %s"):format(trig, expand)
        local replaced = expand:gsub("%%s", "%%s")

        return tsp({
            trig = trig,
            name = name,
            wordTrig = false,
            reparseBuffer = "live",
            matchTSNode = query,
        }, {
            f(function(_, parent)
                return utils.replace_all(parent.snippet.env.LS_TSMATCH, replaced)
            end, {}),
        })
    end
end

local function expr_tsp_nodes(query)
    return function(trig, expand)
        return tsp({
            trig = trig,
            wordTrig = false,
            reparseBuffer = "live",
            matchTSNode = query,
        }, expand)
    end
end

local function quick_type(markers)
    return function(shortcut)
        ---@param str string
        ---@return string?, string?
        local function expect_typename(str)
            local first, rest = str:match("^(%l)(.*)$")
            if first == nil then
                return nil, nil
            end

            local trig = markers[first]
            if trig == nil then
                return nil, nil
            end

            if trig.params == -1 then
                local parameters = {}
                while #rest > 0 do
                    local typename, sub_rest = expect_typename(rest)
                    if typename == nil or sub_rest == nil then
                        break
                    end
                    parameters[#parameters + 1] = typename
                    rest = sub_rest
                end
                return (trig.template):format(table.concat(parameters, ", ")), rest
            end

            if trig.params == 0 then
                local template = trig.template
                if trig.template == "Placeholder" then
                    template = vim.fn.input({
                        prompt = "Custom: ",
                        default = "",
                        cancelreturn = "Poggers"
                    })
                end

                return template, rest
            end

            local parameters = {}
            for _ = 1, trig.params do
                local typename, sub_rest = expect_typename(rest)
                if typename == nil or sub_rest == nil then
                    return nil, rest
                end
                parameters[#parameters + 1] = typename
                rest = sub_rest
            end

            return string.format(trig.template, unpack(parameters)), rest
        end

        local result, rest = expect_typename(shortcut)
        if rest and #rest > 0 then
            print(("After QET eval, rest not empty: %s"):format(rest))
        end
        if result == nil then
            return shortcut
        else
            return result
        end
    end
end

local function one_or_other(query, truth_table)
    return function(trig, typename, expr_callback, type_callback)
        local name = ("(%s) %s"):format(trig, typename)
        return tsp({
            trig = trig,
            name = name,
            wordTrig = false,
            reparseBuffer = "live",
            matchTSNode = {
                query = query,
                query_lang = "rust",
            },
        }, {
            f(function(_, parent)
                local env = parent.snippet.env
                local data = env.LS_TSDATA
                if truth_table[data.prefix.type] then
                    return expr_callback(env.LS_TSMATCH)
                else
                    return type_callback(env.LS_TSMATCH)
                end
            end),
        })
    end
end

local function begin_line_snip(trig, expansion)
    local trigger = "^%s*"..trig.."*$"
    local args = {
        trig = trig,
        snippetType = "autosnippet",
        condition = function(line_to_cursor, matched_trigger, _)
            if matched_trigger == nil or line_to_cursor == nil then
                return false
            end
            return line_to_cursor:match(trigger)
        end
    }
    return s(args, expansion)
end

return {
    expand_types = type_snippet,
    type_surround_gen = type,
    expr_surround_gen = expr_tsp,
    expr_surround_gen_with_nodes = expr_tsp_nodes,
    one_or_other = one_or_other,
    quick_type_gen = quick_type,
    begin_line_snip = begin_line_snip,
    default_qt_snip = function(fn)
        return s({
            trig = "t(%l+)!",
            wordTrig = true,
            regTrig = true,
            snippetType = "autosnippet",
            name = "(t) Quick types",
            desc = "Expands to a type",
        }, {
            f(function(_, snip)
                local shortcut = snip.captures[1]
                return fn(shortcut)
            end),
        })
    end
}
