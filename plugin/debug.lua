local ok, dap = prot_require "dap"
if not ok then
    return
end

local debug_hydra
local setup_func = function ()
    local dap          = require("dap")
    dap.adapters       = require("cathy.config.debug.helper").adapters
    dap.configurations = require("cathy.config.debug.helper").configurations

    dap.defaults.fallback.exception_breakpoints = { "raised" }

    local plug = "dapview_config"
    local open = vim.cmd.DapViewOpen
    local close = vim.cmd.DapViewClose

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
 _m_: step into   _X_: Quit       _<c-cr>_: Condition breakpoint ^
 _q_: step out    _I_: Watch       _L_: Log breakpoint
 ^ ^            ^                 ^  ^
 ^ ^ _c_: Continue/Start          ^  ^   Change window
 ^ ^                              ^  ^     _<c-k>_^
 ^ ^            ^                 ^  _<c-h>_ ^     ^ _<c-l>_
 ^ ^     _<esc>_: exit            ^  ^       _<c-j>_^
 ^ ^            ^
]]

    debug_hydra = require("hydra")({
        hint = hint,
        config = {
            color = "pink",
            on_enter = function ()
                vim.g.debug_mode = true
                vim.cmd.DapViewOpen()
            end,
            on_exit = function ()
                vim.g.debug_mode = nil
                vim.cmd.DapViewClose()
            end,
            hint = {
                position = "middle-right",
                float_opts = {
                    border = "rounded",
                }
            },
        },
        name = "dap",
        mode = { "n" },
        heads = {
            { "<cr>", function() dap.toggle_breakpoint() end, { silent = true } },
            { "<c-cr>", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { silent = true }},
            { "L", function()
                vim.ui.input({ prompt = "Log point message: " }, function(input)
                    dap.set_breakpoint(nil, nil, input)
                end)
            end, { silent = false } },
            { "I", vim.cmd.DapViewWatch, { silent = true, nowait = true } },
            { "m", function() dap.step_into() end, { silent = true, nowait = true } },
            { "o", function() dap.step_over() end, { silent = true } },
            { "q", function() dap.step_out() end, { silent = true } },
            { "c", function() dap.continue() end, { silent = true } },
            { "J", function() dap.run_to_cursor() end, { silent = true } },
            { "X", function() dap.disconnect({ terminateDebuggee = false }) end, { silent = true } },
            { "<c-h>", "<c-w><c-h>", { silent = true } },
            { "<c-j>", "<c-w><c-j>", { silent = true } },
            { "<c-k>", "<c-w><c-k>", { silent = true } },
            { "<c-l>", "<c-w><c-l>", { silent = true } },
            { "<esc>", nil, { exit = true,  silent = true } },
        }
    })
end

require("cathy.utils").lazy_keymap {
    mode = "n",
    setup = setup_func,
    lhs = "<leader>z",
    rhs = function ()
        debug_hydra:activate()
    end,
}

vim.fn.sign_define("DapBreakpoint", { text="", texthl="Error", linehl="", numhl="" })
