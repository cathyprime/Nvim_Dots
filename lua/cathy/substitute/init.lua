local default_config = require "luasnip.default_config"
local utils = setmetatable({}, {
    __index = function (_, key)
        return require("cathy.substitute.utils")[key]
    end
})

local replace_func = [[v:lua.require'cathy.substitute'.replace]]
local sub_func = [[v:lua.require'cathy.substitute'.sub()]]

local esc = function ()
    vim.api.nvim_feedkeys(vim.keycode "<esc>", 'n', false)
end

local keys = function (cmd)
    vim.api.nvim_feedkeys(cmd, 'n', false)
end

local cache = {
    query = nil,
    replace = nil,
}

local input = function (tbl)
    local cb = tbl.cb
    tbl.cb = nil
    vim.ui.input(tbl, function (inp)
        if not inp then
            esc()
            return
        end
        cb(inp)
    end)
end

local prompt = {
    query = function ()
        return "Query replace in region"
    end,
    replace = function ()
        local prmpt = "Query replacing "
        if cache.query then
            prmpt = prmpt .. [["]] .. cache.query .. [[" ]]
        end
        return prmpt .. "with"
    end
}

local prelude = function (linewise)
    if linewise then
        return function ()
            vim.go.operatorfunc = replace_func
            return "g@_"
        end
    end
    return function ()
        vim.go.operatorfunc = replace_func
        return "g@"
    end
end

local replace = function (from, to)
    local from_case = utils.caseof(from)
    if not from_case then
        return to
    end
    return utils.convert(to, from_case)
end

local make_cb_chain = function (regex)
    return function (inp)
        cache.query = inp
        input {
            prompt = prompt.replace(),
            default = cache.replace,
            cb = function (inp)
                cache.replace = inp
                esc()
                keys(string.format(
                    vim.keycode(regex),
                    utils.make_regex(cache.query),
                    sub_func
                ))
                vim.go.operatorfunc = replace_func
            end
        }
    end
end

local set = function (tbl)
    vim.keymap.set(
        tbl.mode or "n",
        string.format("<Plug>(%s)", tbl.name),
        tbl.cb,
        {
            silent = false,
            expr = true
        }
    )
end

set {
    name = "substitute",
    cb = prelude(false)
}

set {
    name = "substitute",
    mode = "x",
    cb = function ()
        input {
            prompt = prompt.query(),
            default = cache.query,
            cb = make_cb_chain([[<cmd>'<,'>s#%s#\=%s#gc<cr>]])
        }
    end,
}

set {
    name = "substitute-linewise",
    cb = prelude(true)
}

return {
    replace = function ()
        input {
            prompt = prompt.query(),
            default = cache.query,
            cb = make_cb_chain([[<cmd>'[,']s#%s#\=%s#gc<cr>]])
        }
    end,
    sub = function ()
        local submatch = vim.fn.submatch(0)
        return replace(submatch, cache.replace)
    end,
}
