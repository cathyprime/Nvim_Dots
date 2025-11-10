return function(opts)
    local co
    local result
    local done = false

    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniPickStop",
        once = true,
        callback = function ()
            done = true
        end
    })
    co = coroutine.create(function()
        opts.cb = function(return_value)
            result = return_value
        end
        require("cathy.utils.mini.locpick")(opts)

        while not done do
            coroutine.yield()
        end
    end)

    while coroutine.status(co) ~= "dead" do
        coroutine.resume(co)
    end

    return result
end
