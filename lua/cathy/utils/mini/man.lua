local pick = require("mini.pick")

return function (opts)
    local items = {}

    vim.system(
        { "man", "-k", "." },
        { text = true },
        function(obj)
            if obj.code ~= 0 or not obj.stdout then
                vim.notify("Failed to list man pages", vim.log.levels.ERROR)
                return
            end

            for line in obj.stdout:gmatch("[^\n]+") do
                local page = line:match("^([^%s]+)")
                if page then
                    table.insert(items, {
                        text = line,
                        page = page,
                    })
                end
            end


            vim.schedule(function()
                pick.start(vim.tbl_deep_extend("force", {
                    window = {
                        prompt_prefix = opts.prompt_prefix
                    },
                    source = {
                        name = "Man pages",
                        items = items,
                        choose = function(item)
                            if item then
                                vim.cmd("Man " .. item.page)
                            end
                        end,
                    },
                }, opts))
            end)
        end
    )
end
