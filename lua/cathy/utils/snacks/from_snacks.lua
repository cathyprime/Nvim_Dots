local function wrap_in_function(path, args)
    return function()
        if #path == 1 then
            return Snacks[path[1]](unpack(args or {}))
        else
            return Snacks[path[1]][path[2]](unpack(args or {}))
        end
    end
end

return setmetatable({}, {
    __index = function(_, key)
        return setmetatable({}, {
            __call = function(_, ...)
                return wrap_in_function({key}, {...})
            end,
            __index = function(_, subkey)
                return setmetatable({}, {
                    __call = function(_, ...)
                        return wrap_in_function({key, subkey}, {...})
                    end,
                    __index = function(_, method)
                        return wrap_in_function({key, subkey, method})
                    end
                })
            end
        })
    end
})
