local home = os.getenv("HOME")

local function truncpath(path)
    return path:gsub(home, "~")
end

local function filename(item, picker)
    local ret = {}
    if not item.file then
        return ret
    end
    local path = Snacks.picker.util.path(item) or item.file
    path = truncpath(path)
    local name, cat = path, "file"
    if item.buf and vim.api.nvim_buf_is_loaded(item.buf) then
        name = vim.bo[item.buf].filetype
        cat = "filetype"
    elseif item.dir then
        cat = "directory"
    end

    if picker.opts.icons.files.enabled ~= false then
        local icon, hl = Snacks.util.icon(name, cat)
        if item.dir and item.open then
            icon = " "
        end
        local padded_icon = icon:sub(-1) == " " and icon or icon .. " "
        ret[#ret + 1] = { padded_icon, hl, virtual = true }
    end

    local base_hl = item.dir and "SnacksPickerDirectory" or "SnacksPickerFile"
    local function is(prop)
        local it = item
        while it do
            if it[prop] then
                return true
            end
            it = it.parent
        end
    end

    if is("ignored") then
        base_hl = "SnacksPickerPathIgnored"
    elseif is("hidden") then
        base_hl = "SnacksPickerPathHidden"
    end
    local dir_hl = "SnacksPickerDir"

    if picker.opts.formatters.file.filename_only then
        path = vim.fn.fnamemodify(item.file, ":t")
        ret[#ret + 1] = { path, base_hl, field = "file" }
    else
        local dir, base = path:match("^(.*)/(.+)$")
        if base and dir then
            if picker.opts.formatters.file.filename_first then
                ret[#ret + 1] = { base, base_hl, field = "file" }
                ret[#ret + 1] = { " " }
                ret[#ret + 1] = { dir, dir_hl, field = "file" }
            else
                ret[#ret + 1] = { dir .. "/", dir_hl, field = "file" }
                ret[#ret + 1] = { base, base_hl, field = "file" }
            end
        else
            ret[#ret + 1] = { path, base_hl, field = "file" }
        end
    end
    if item.pos and item.pos[1] > 0 then
        ret[#ret + 1] = { ":", "SnacksPickerDelim" }
        ret[#ret + 1] = { tostring(item.pos[1]), "SnacksPickerRow" }
        if item.pos[2] > 0 then
            ret[#ret + 1] = { ":", "SnacksPickerDelim" }
            ret[#ret + 1] = { tostring(item.pos[2]), "SnacksPickerCol" }
        end
    end
    ret[#ret + 1] = { " " }
    return ret
end

return function (item, picker)
    local ret = {}

    if item.label then
        ret[#ret + 1] = { item.label, "SnacksPickerLabel" }
        ret[#ret + 1] = { " ", virtual = true }
    end

    vim.list_extend(ret, filename(item, picker))

    if item.comment then
        table.insert(ret, { item.comment, "SnacksPickerComment" })
        table.insert(ret, { " " })
    end

    if item.line then
        Snacks.picker.highlight.format(item, item.line, ret)
        table.insert(ret, { " " })
    end
    return ret
end
