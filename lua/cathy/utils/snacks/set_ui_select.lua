vim.ui.select = function (items, opts, on_choice)
    assert(type(on_choice) == "function", "on_choice must be a function")
    opts = opts or {}

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

    do
        local lpeg = require("lpeg")
        local space = lpeg.S': \t\n\v\f\r'
        local nospace = 1 - space
        local ptrim = space^0 * lpeg.C((space^0 * nospace^1)^0)
        local match = lpeg.match
        opts.prompt = (match(ptrim, opts.prompt):gsub("^%l", string.upper))
    end

    local prompt = string.format(" %s :: ", opts.prompt or "Select")
    local completed = false

    return Snacks.picker.pick({
        source = "select",
        items = finder_items,
        format = Snacks.picker.format.ui_select(opts.kind, #items),
        prompt = prompt,
        layout = {
            preset = "ivy",
            preview = false,
            layout = {
                height = math.min(#items + 1, 13),
            },
        },
        win = {
            input = {
                keys = {
                    ["<tab>"] = { "complete_from_selected", mode = { "i", "n" }, desc = "complete from selected" }
                },
            },
        },
        actions = {
            complete_from_selected = function (picker, item)
                local new_prompt = item.item
                vim.api.nvim_buf_set_lines(picker.input.win.buf, 0, -1, false, { new_prompt })
                vim.api.nvim_win_set_cursor(picker.input.win.win, { 1, #new_prompt })
                picker:find()
            end,
            confirm = function (picker, item)
                if completed then
                    return
                end
                completed = true
                local prompt = vim.api.nvim_buf_get_lines(picker.input.win.buf, 0, -1, false)[1]
                picker:close()
                vim.schedule(function ()
                    on_choice(item and item.item or prompt,
                              item and item.idx or 1)
                end)
            end,
        },
        on_close = function ()
            if completed then
                return
            end
            completed = true
            vim.schedule(on_choice)
        end,
    })
end
