local input = function (name, prompt)
    local cache = require("cathy.tasks.utils.cache")
    local t = cache.types
    local co = coroutine.running()
    assert(co, "must be in coroutine")

    local result

    vim.ui.input({
        prompt = prompt,
        default = cache.get(t.inputs, name)
    }, function (user_input)
        if user_input then
            cache.set(t.inputs, name, user_input)
            result = user_input
        end

        coroutine.resume(co)
    end)

    return result
end

return {
    input = input
}
