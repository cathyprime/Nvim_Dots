local ok, quicker = prot_require "quicker"
if not ok then
    return
end

quicker.setup({
    opts = {
        number = true,
        relativenumber = true,
        signcolumn = "yes"
    },
    keys = {
        {
            "<c-l>",
            function ()
                if vim.b.compile_mode then
                    return
                end
                quicker.refresh()
            end,
            desc = "Refresh quickfix list",
        },
        {
            "+",
            function()
                if vim.b.compile_mode then
                    return
                end
                quicker.expand({ before = 2, after = 2, add_to_existing = true })
            end,
            desc = "Expand quickfix context"
        },
        {
            "-",
            function ()
                if vim.b.compile_mode then
                    return
                end
                quicker.collapse()
            end,
            desc = "Collapse quickfix context"
        }
    },
})

local gen = function (try, otherwise)
    return function ()
        local ok = pcall(vim.cmd, try)
        if not ok then
            pcall(vim.cmd, otherwise)
        end
    end
end

local jumps = {
    qf = {
        next = gen("cnext", "cfirst"),
        prev = gen("cprev", "clast"),
    },
    loclist = {
        next = gen("lnext", "llast"),
        prev = gen("lprev", "lfirst"),
    },
}

local jump = function (forward)
    local has_loclist = vim.fn.getloclist(0, {winid=0}).winid ~= 0
    local list_type = has_loclist and "loclist" or "qf"
    local direction = forward and "next" or "prev"
    jumps[list_type][direction]()
end

local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
local wrapped = ts_repeat_move.make_repeatable_move(
    function (move_opts)
        if move_opts.forward then
            jump(true)
        else
            jump(false)
        end
    end
)
local jump_next = function () wrapped({ forward = true }) end
local jump_prev = function () wrapped({ forward = false }) end

local map = function (opts)
    local map_opts = {}
    for k, v in pairs(opts) do
        if type(k) ~= "number" then
            map_opts[k] = v
        end
    end
    vim.keymap.set("n", opts[1], opts[2], map_opts)
end

map {
    "]c", jump_next, desc = "Next quickfix item"
}

map {
    "[c", jump_prev, desc = "Prev quickfix item"
}

map {
    "<leader>q", function()
        local has_loclist = vim.fn.getloclist(0, {winid=0}).winid ~= 0
        if has_loclist then
            quicker.close({ loclist = true })
            return
        end
        quicker.toggle({
            height = math.floor(vim.opt.lines:get() * 0.6),
            open_cmd_mods = { split = "botright" }
        })
    end
}

map {
    "<leader>Q",
    function() quicker.toggle({
        height = math.floor(vim.opt.lines:get() * 0.6),
        open_cmd_mods = { split = "botright" },
        loclist = true
    }) end
}
