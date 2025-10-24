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

return function ()
    local pick = require("mini.pick")
    pick.start({
        source = {
            items = make_items(vim.uv.cwd()),
            name = "Loc_Pick",
            cwd = vim.uv.cwd(),
            show = function(buf_id, items, query)
                require("mini.pick").default_show(buf_id, items, query, { show_icons = true })
            end,
            choose = function (item)
                vim.print(item)
            end
        }
    })
end
