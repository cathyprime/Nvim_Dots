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
    local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
    local funcs = { ts_repeat_move.make_repeatable_move_pair(self.rhs[1], self.rhs[2]) }
    self.rhs = funcs
    for x = 1, 2 do
        self.opts.desc = type(self.desc) == "table"
            and self.desc[x]
            or self.desc
        vim.keymap.set(self.mode, self.lhs[x], self.rhs[x], self.opts)
    end
end

return {
    set_pair = function (opts)
        opts = setmetatable(opts or {}, Mappings)
        opts:ensure_needed()
        opts:map()
    end
}
