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

    local buttons = {
        { "_m_", "step into" },
        { "_o_", "step over" },
        { "_q_", "step out" },
        { "_u_", "toggle" },
        { "_<cr>_", "Breakpoint" },
        { "_<c-cr>_", "Cond break" },
        { "_X_", "Quit" },
        { "_I_", "Watch" },
        { "_L_", "Log point" },
        { "_c_", "Continue/Start" },
        { "_J_", "to cursor" },
        { "_<esc>_", "exit" },
    }

    local function create_hint(buttons)
        local half = math.ceil(#buttons / 2)
        local row1, row2 = {}, {}

        for i = 1, half do
            table.insert(row1, buttons[i])
        end
        for i = half + 1, #buttons do
            table.insert(row2, buttons[i])
        end

        local max_key_widths = {}
        local max_widths = {}
        for i = 1, half do
            local k1 = #row1[i][1]
            local k2 = row2[i] and #row2[i][1] or 0
            max_key_widths[i] = math.max(k1, k2)

            local w1 = max_key_widths[i] + 4 + #row1[i][2]  -- 4 = " :: "
            local w2 = row2[i] and (max_key_widths[i] + 4 + #row2[i][2]) or 0
            max_widths[i] = math.max(w1, w2)
        end

        local function format_row(btns)
            local parts = {}
            for i, btn in ipairs(btns) do
                local key_padded = string.rep(" ", max_key_widths[i] - #btn[1]) .. btn[1]
                local text = key_padded .. " :: " .. btn[2]
                local padded = text .. string.rep(" ", max_widths[i] - #text)
                table.insert(parts, padded)
            end
            return table.concat(parts, " | ")
        end

        local line1 = format_row(row1)
        local line2 = format_row(row2)
        local max_len = math.max(#line1, #line2)
        local padding = math.floor((vim.o.columns - max_len) / 2)

        return string.rep(" ", padding) .. "^ " .. line1 .. " ^\n" ..
               string.rep(" ", padding) .. "^ " .. line2 .. " ^"
    end

    debug_hydra = require("hydra")({
        hint = create_hint(buttons),
        config = {
            color = "pink",
            on_enter = function ()
                vim.g.debug_mode = true
            end,
            on_exit = function ()
                vim.g.debug_mode = nil
            end,
            hint = {
                type = "cmdline",
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
            { "u", vim.cmd.DapViewToggle, { silent = true } },
            { "m", function() dap.step_into() end, { silent = true, nowait = true } },
            { "o", function() dap.step_over() end, { silent = true } },
            { "q", function() dap.step_out() end, { silent = true } },
            { "c", function() dap.continue() end, { silent = true } },
            { "J", function() dap.run_to_cursor() end, { silent = true } },
            { "X", function() dap.disconnect({ terminateDebuggee = false }) end, { silent = true } },
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
