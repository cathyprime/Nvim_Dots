local input = function (name, prompt)
    local cache = require("cathy.tasks.utils.internal").cache
    local t = require("cathy.tasks.utils.internal").cache_types
    local co = coroutine.running()
    assert(co, "must be in coroutine")

    local result

    vim.ui.input({
        prompt = prompt,
        default = cache.get(t.inputs, name)
    }, function (input)
        if input then
            cache.set(t.inputs, name, input)
            result = input
        end

        coroutine.resume(co)
    end)

    return result
end

return {
    input = input
}
