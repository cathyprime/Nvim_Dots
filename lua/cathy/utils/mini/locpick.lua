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

        local fs_type = type == "directory" and type or "file"
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
        { preserve_order = true, sync = true }
    )
end

local complete = function ()
    local matches = MiniPick.get_picker_matches()
    if not matches then return end
    if not matches.current then return end
    local query = MiniPick.get_picker_query()
    if not query then return end

    local cur_path = get_path(query, function (x) return x end)
    local new_query = cur_path .. matches.current.text
    local real_path = vim.uv.fs_realpath(vim.fn.fnamemodify(new_query, ":p"))
    if vim.fn.isdirectory(real_path) == 1 then
        new_query = new_query .. "/"
    end
    MiniPick.set_picker_query(vim.split(new_query, ""))
    MiniPick.refresh()
end

local go_home = function ()
    MiniPick.set_picker_query({ "~", "/"})
    MiniPick.refresh()
end

return function ()
    local pick = require("mini.pick")
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
            complete = { char = "<tab>", func = complete },
            go_home = { char = "<c-h>", func = go_home }
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
            choose = function (item)
                vim.print(item)
            end
        }
    })
end
