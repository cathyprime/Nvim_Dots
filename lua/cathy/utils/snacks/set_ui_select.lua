vim.ui.select = function (items, opts, on_choice)
    assert(type(on_choice) == "function", "on_choice must be a function")
    opts = opts or {}

    ---@type snacks.picker.finder.Item[]
    local finder_items = {}
    for idx, item in ipairs(items) do
        local text = (opts.format_item or tostring)(item)
        table.insert(finder_items, {
            formatted = text,
            text = idx .. " " .. text,
            item = item,
            idx = idx,
        })
    end

    local title = opts.prompt or "Select"
    title = title:gsub("^%s*", ""):gsub("[%s:]*$", "")

    ---@type snacks.picker.finder.Item[]
    return Snacks.picker.pick({
        source = "ivy",
        items = finder_items,
        format = Snacks.picker.format.ui_select(opts.kind, #items),
        title = title,
        prompt = " Select :: ",
        layout = {
            preview = false,
            layout = {
                height = math.floor(math.min(vim.o.lines * 0.8 - 10, #items + 2) + 0.5),
            },
        },
        actions = {
            confirm = function(picker, item)
                picker:close()
                vim.schedule(function()
                    on_choice(item and item.item, item and item.idx)
                end)
            end,
        },
    })
end
