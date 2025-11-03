local sorter = function(items)
    local res = vim.tbl_map(function(x)
        return {
            fs_type = x.fs_type, path = x.path, text = x.text,
            is_dir = x.fs_type == 'directory', lower_name = x.text:lower(),
        }
    end, items)

    local compare = function(a, b)
        if a.is_dir and not b.is_dir then return true end
        if not a.is_dir and b.is_dir then return false end

        return a.lower_name < b.lower_name
    end

    table.sort(res, compare)

    return vim.tbl_map(function(x)
        return {
            fs_type = x.fs_type,
            path = x.path,
            text = x.text
        }
    end, res)
end

local make_items = function (path)
    path = vim.fs.normalize(path)
    local uv = vim.uv
    local dir = uv.fs_scandir(path)
    local items = {
        { fs_type = "directory", path = vim.fn.fnamemodify(path, ":h"), text = ".." },
        { fs_type = "directory", path = path, text = "." },
    }

    while true do
        local name, type = uv.fs_scandir_next(dir)
        if not name then break end

        local fs_type
        if type == "link" then
            local full_path = string.format("%s/%s", path, name)
            local real_path = uv.fs_realpath(full_path)
            if not real_path then
                fs_type = "link"
            else
                local resolved = uv.fs_stat(real_path).type
                fs_type = resolved == "directory" and resolved or "file"
            end
        else
            fs_type = type == "directory" and type or "file"
        end
        table.insert(items, {
            fs_type = fs_type,
            path = string.format("%s/%s", path, name),
            text = name .. (fs_type == "directory" and "/" or "")
        })
    end

    return sorter(items)
end

local norm = vim.fs.normalize
local get_path = function (query, n)
    n = n or norm
    local prompt = table.concat(query)
    local last_slash = prompt:match(".*()/")
    if last_slash then
        return n(prompt:sub(1, last_slash))
    else
        return n(prompt)
    end
end

local just_path = function (query)
    while query[#query] ~= "/" do
        table.remove(query, #query)
    end
    return query
end

local get_match = function (query)
    local prompt = table.concat(query)
    local last_slash = prompt:match(".*()/")
    if last_slash then
        return vim.split(prompt:sub(last_slash + 1), "")
    else
        return query
    end
end

local last_path = nil
local matcher = function (stritems, inds, query)
    local path = get_path(query)
    if path ~= last_path then
        last_path = path
        if vim.fn.isdirectory(path) == 1 then
            MiniPick.set_picker_items(make_items(path))
        else
            MiniPick.set_picker_items({})
        end
        return nil
    end

    if query[#query] == "/" then
        return inds
    end

    return MiniPick.default_match(
        stritems,
        inds,
        get_match(query),
        { preserve_order = false, sync = true }
    )
end

local go_home = function ()
    MiniPick.set_picker_query({ "~", "/"})
    MiniPick.refresh()
end

local shorten_query = function (query)
    if query[1] == "~" then
        return query
    end
    local home = vim.split(os.getenv "HOME", "")
    if #query < #home then
        return query
    end
    for i = 1, #home do
        if query[i] ~= home[i] then
            return query
        end
    end
    return { "~", unpack(query, len+1) }
end

local expand_query = function (query)
    if query[1] ~= "~" then
        return query
    end
    table.remove(query, 1)
    return vim.fn.extend(vim.split(os.getenv "HOME", ""), query)
end

local append_slash = function ()
    local query = MiniPick.get_picker_query()
    if query[#query] == "/" then
        return
    end
    query[#query+1] = "/"
    MiniPick.set_picker_query(
        shorten_query(query)
    )
end

local has_home = function (query)
    local home = vim.split(os.getenv "HOME", "")
    if query[1] == "~" then
        return true
    end
    if #query < #home then
        return false
    end
    return true
end

local dir_up = function (query)
    if #query == 2 and query[1] == "~" and query[2] == "/" then
        MiniPick.set_picker_query(
            vim.split(vim.fn.fnamemodify(os.getenv "HOME", ":h") .. "/", "")
        )
        return
    end
    local slash_count = vim.iter(query)
        :fold(0, function (acc, v)
            if v == "/" then
                acc = acc + 1
            end
            return acc
        end)

    if slash_count > 1 then
        table.remove(query, #query)
        while query[#query] ~= "/" do
            table.remove(query, #query)
        end
    end

    MiniPick.set_picker_query(query)
    MiniPick.refresh()
end

local complete = function ()
    local matches = MiniPick.get_picker_matches()
    if not matches then return end
    if not matches.current then return end

    if matches.current.text == "." then
        return
    end

    local query = MiniPick.get_picker_query()
    if matches.current.text == ".." then
        dir_up(just_path(query))
        return
    end

    local cur_path = get_path(query, function (x) return x end)
    local new_query = cur_path .. matches.current.text
    local real_path = vim.uv.fs_realpath(vim.fn.fnamemodify(new_query, ":p"))
    MiniPick.set_picker_query(
        shorten_query(vim.split(new_query, ""))
    )
    MiniPick.refresh()
end

local delete_or_up = function ()
    local query = MiniPick.get_picker_query()
    if query[#query] == "/" then
        dir_up(query)
        return
    end
    table.remove(query, #query)
    MiniPick.set_picker_query(query)
end

local delete_word = function ()
    local query = MiniPick.get_picker_query()
    if query[#query] == "/" then
        dir_up(query)
        return
    end

    MiniPick.set_picker_query(just_path(query))
end

return function (opts)
    local pick = require("mini.pick")
    opts.cb = opts.cb or pick.default_choose
    local start = require("cathy.utils").cur_buffer_path()
    vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "MiniPickStart",
        callback = function ()
            MiniPick.set_picker_query(vim.split(start:gsub(os.getenv "HOME", "~"), ""))
        end
    })
    last_path = norm(start)
    pick.start({
        mappings = {
            caret_left = "",
            caret_right = "",
            delete_char_right = "",
            delete_word = "",
            delete_left = "",
            slash = { char = "/", func = append_slash },
            complete = { char = "<tab>", func = complete },
            go_home = { char = "<c-h>", func = go_home },
            delete_or_up = { char = "<bs>", func = delete_or_up },
            delete_w = { char = "<c-w>", func = delete_word },
            delete_all = { char = "<c-u>", func = function () MiniPick.set_picker_query({"/"}) end }
        },
        window = {
            prompt_prefix = " Find File :: "
        },
        source = {
            items = make_items(start),
            name = "Loc_Pick",
            cwd = start,
            match = matcher,
            show = function(buf_id, items, query)
                require("mini.pick").default_show(buf_id, items, get_match(query), { show_icons = true })
            end,
            choose = opts.cb
        }
    })
end
