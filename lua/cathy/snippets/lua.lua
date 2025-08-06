---@diagnostic disable: undefined-global

return {
    s("req", fmt([[local {varname} = require "{path}"]], {
        varname = f(function(import_name)
            local parts = vim.split(import_name[1][1], "%.")
            local str = parts[#parts] or ""
            str = str:gsub("-", "_") or str
            return str
        end, {1}),
        path = i(1)
    })),

    s("preq", fmt([[
    local ok, {varname} = prot_require "{path}"
    if not ok then
        return
    end
    ]], {
        varname = f(function(import_name)
            local parts = vim.split(import_name[1][1], "%.")
            local str = parts[#parts] or ""
            str = str:gsub("-", "_") or str
            return str
        end, {1}),
        path = i(1)
    })),

    s("reqc", fmt([[require("{}").{}({})]], {
        i(1, "module"),
        i(2, "setup"),
        i(0)
    })),

    s("fn", fmt([[
    {scope}function{space}{name}({args})
        {body}
    end
    ]], {
        scope = f(function(name)
            if name[1][1] == "" then
                return ""
            elseif string.match(name[1][1], "^[A-Z_]+$")  then
                return ""
            else
                return "local "
            end
        end, { 1 }),
        space = f(function(name)
            if name[1][1] == "" then
                return ""
            else
                return " "
            end
        end, { 1 }),
        name = i(1),
        args = i(2),
        body = i(0)
    })),

    s("p", fmt([[print({})]], {
        i(0),
    })),

    s("noti", fmt([[vim.notify("{}", {}, {{{}}})]], {
        i(1, "message"),
        i(2, "loglevel"),
        i(3, "")
    })),

    s("m", fmt([[
    function M.{name}({args})
        {body}
    end
    ]], {
        name = i(1, "name"),
        args = i(2),
        body = i(3),
    })),

    s("autocmd", fmt([[
    vim.api.nvim_create_autocmd({event}, {{
        once = {once},
        {fn},
    }})
    ]], {
        event = c(1, {
            sn(nil, fmt([["{}"]], { i(1, "event") })),
            sn(nil, fmt([[{<>}]], { i(1, "event") }, { delimiters = "<>" })),
        }),
        once = c(2, {
            t"false",
            t"true",
        }),
        fn = c(3, {
            isn(nil, fmt([[
            callback = function({args})
                {body}
            end
            ]], {
                args = i(1),
                body = i(2),
            }), "$PARENT_INDENT\t"),
            sn(nil, fmt([[command = "{}"]], { i(1, "command") })),
        }),
    }))
}
