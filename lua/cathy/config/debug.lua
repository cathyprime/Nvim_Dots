local ok, dap = prot_require "dap"
if not ok then
    return
end

local make_simple_layout = function (opts)
    return {
        elements = {
            { id = opts.left, size = opts.size or 0.60 },
            { id = opts.right, size = 1 - (opts.size or 0.60) }
        },
        size = opts.height or 12,
        position = opts.position or "bottom",
    }
end

local layouts = {
    make_simple_layout {
        left = "watches",
        right = "console",
        position = "right",
        height = 60
    },
    make_simple_layout {
        left = "scopes",
        right = "stacks",
        position = "right",
        height = 60
    },
}

local clamp = function (idx)
    return ((idx - 1) % #layouts) + 1
end

local indexer = {
    current = 1,
    next = function (self)
        self.current = clamp(self.current + 1)
        return self.current
    end,
    prev = function (self)
        self.current = clamp(self.current - 1)
        return self.current
    end
}

local dap   = require("dap")
local dapui = require("dapui")
---@diagnostic disable-next-line: different-requires
dap.configurations = require("cathy.config.debug.helper").configurations
---@diagnostic disable-next-line: different-requires
dap.adapters       = require("cathy.config.debug.helper").adapters

---@diagnostic disable-next-line
dapui.setup({
    expand_lines = false,
    render = {
        max_type_length = 0,
    },
    layouts = layouts
})

dap.defaults.fallback.exception_breakpoints = { "raised" }

local plug = "dapui_config"
local open = function () dapui.open({ layout = 2 }) end
local close = function () dapui.close() end

for event, func in pairs({
    attach = open,
    launch = open,
    event_terminated = close,
    event_exited = close
}) do
    dap.listeners.before[event][plug] = func
end

local hint = [[
 _o_: step over   _J_: to cursor  _<cr>_: Breakpoint
 _m_: step into   _X_: Quit        _B_: Condition breakpoint ^
 _q_: step out    _K_: Float       _L_: Log breakpoint
 ^ ^              _W_: Watch
 ^ ^            ^                 ^  ^
   _\^_: Prev layout                  _$_: Next layout
 ^ ^ _c_: Continue/Start          ^  ^   Change window
 ^ ^                              ^  ^     _<c-k>_^
 ^ ^            ^                 ^  _<c-h>_ ^     ^ _<c-l>_
 ^ ^     _<esc>_: exit            ^  ^       _<c-j>_^
 ^ ^            ^
]]

local debug_hydra = require("hydra")({
    hint = hint,
    config = {
        color = "pink",
        on_enter = function ()
            vim.g.debug_mode = true
            indexer.current = 2
            pcall(dapui.open, { layout = indexer.current })
        end,
        on_exit = function ()
            vim.g.debug_mode = nil
            pcall(dapui.close)
        end,
        hint = {
            position = "bottom",
            float_opts = {
                border = "rounded",
            }
        },
    },
    name = "dap",
    mode = { "n" },
    heads = {
        { "<cr>", function() dap.toggle_breakpoint() end, { silent = true } },
        { "B", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { silent = true }},
        { "L", function()
            vim.ui.input({ prompt = "Log point message: " }, function(input)
                dap.set_breakpoint(nil, nil, input)
            end)
        end, { silent = false } },
        { "m", function() dap.step_into() end, { silent = true, nowait = true } },
        { "o", function() dap.step_over() end, { silent = true } },
        { "q", function() dap.step_out() end, { silent = true } },
        { "W", function() dapui.elements.watches.add(vim.fn.expand("<cword>")) end, { silent = true } },
        { "^", function ()
            pcall(dapui.close, { layout = indexer.current })
            dapui.open({ layout = indexer:prev() })
        end },
        { "$", function ()
            pcall(dapui.close, { layout = indexer.current })
            dapui.open({ layout = indexer:next() })
        end },
        { "u", function()
            local ok, _ = pcall(dapui.toggle, { layout = 1 })
            if not ok then
                vim.notify("no active session", vim.log.levels.INFO)
            end
        end, { silent = false } },
        { "c", function() dap.continue() end, { silent = true } },
        { "K", function()
            dapui.float_element(nil, {
                width = 100,
                height = 30,
                position = "center",
                enter = true
            })
        end, { silent = true } },
        { "J", function() dap.run_to_cursor() end, { silent = true } },
        { "X", function() dap.disconnect({ terminateDebuggee = false }) end, { silent = true } },
        { "<c-h>", "<c-w><c-h>", { silent = true } },
        { "<c-j>", "<c-w><c-j>", { silent = true } },
        { "<c-k>", "<c-w><c-k>", { silent = true } },
        { "<c-l>", "<c-w><c-l>", { silent = true } },
        { "<esc>", nil, { exit = true,  silent = true } },
    }
})

vim.keymap.set("n", "<leader>z", function()
    local ok, zen = pcall(require, "zen-mode.view")
    if ok and zen.is_open() then
        require("zen-mode").close()
    end
    debug_hydra:activate()
end)

vim.fn.sign_define("DapBreakpoint", { text="", texthl="Error", linehl="", numhl="" })
