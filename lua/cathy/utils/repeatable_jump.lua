local Mappings = {}
Mappings.__index = Mappings
function Mappings:ensure_needed()
    if not self.rhs then
        self.rhs = {
            function () vim.cmd("norm! " .. self.lhs[1]) end,
            function () vim.cmd("norm! " .. self.lhs[2]) end,
        }
    end

    local opts = vim.iter(pairs(self))
        :filter(function (key, value)
            return key ~= "lhs" and key ~= "rhs" and key ~= "mode"
        end)
        :fold({}, function (acc, key, value)
            acc[key] = value
            return acc
        end)
    local description
    self.opts = opts
    if opts.desc ~= nil then
        description = self.opts.desc
    end
    if type(description) == "table" then
        self.desc = { description[1], description[2] }
    else
        self.desc = description
    end

    return self
end

function Mappings:map()
    local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
    local f_func = self.rhs[1]
    local b_func = self.rhs[2]
    local general_f = function (move_opts)
        if not move_opts then
            return
        end
        if move_opts.forward then
            f_func()
        else
            b_func()
        end
    end
    local wrapped = ts_repeat_move.make_repeatable_move(general_f)
    self.rhs = function (x)
        return function ()
            wrapped({ forward = x == 1 and true or false })
        end
    end
    for x = 1, 2 do
        self.opts.desc = type(self.desc) == "table"
            and self.desc[x]
            or self.desc
        vim.keymap.set(self.mode, self.lhs[x], self.rhs(x), self.opts)
    end
end

return {
    set_pair = function (opts)
        opts = setmetatable(opts or {}, Mappings)
        opts:ensure_needed()
        opts:map()
    end
}
