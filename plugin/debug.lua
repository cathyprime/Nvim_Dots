local ok, dap = prot_require "dap"
if not ok then
    return
end

require "dap-view" .setup {
    windows = {
        height = 0.4
    }
}

local debug_hydra
local setup_func = function ()
    local dap          = require("dap")
    dap.adapters       = require("cathy.config.debug.helper").adapters
    dap.configurations = require("cathy.config.debug.helper").configurations

    dap.defaults.fallback.exception_breakpoints = { "raised" }

    local run_or_continue = function()
        if dap.session() then
            dap.continue()
            return
        end

        local ft = vim.bo.filetype
        local configs = dap.configurations[ft]

        if not configs or #configs == 0 then
            vim.notify(
                "No debug configurations for filetype: " .. ft,
                vim.log.levels.WARN
            )
            return
        end

        local function resolve_and_run(config)
            local cfg = vim.tbl_deep_extend("force", {}, config)

            local function resolve_args(cb)
                if type(cfg.args) == "function" then
                    cfg.args(function(resolved)
                        cfg.args = resolved or {}
                        cb(cfg)
                    end)
                else
                    cb(cfg)
                end
            end

            if type(cfg.program) == "function" then
                cfg.program(function(item)
                    if not item then return end
                    cfg.program = item.path
                    resolve_args(function(cfg)
                        dap.run(cfg)
                    end)
                end)
            else
                resolve_args(function(cfg)
                    dap.run(cfg)
                end)
            end
        end

        vim.ui.select(configs, {
            prompt = "Select debug configuration:",
            format_item = function(c)
                return c.name or c.type
            end,
        }, function(choice)
                if choice then
                    resolve_and_run(choice)
                end
            end)
    end

    local buttons = {
        { "_m_", "step into" },
        { "_u_", "toggle" },
        { "_L_", "Log point" },
        { "_<cr>_", "Breakpoint" },
        { "_o_", "step over" },
        { "_c_", "Continue/Start" },
        { "_I_", "Watch" },
        { "_<c-cr>_", "Cond break" },
        { "_q_", "step out" },
        { "_X_", "Quit" },
        { "_J_", "to cursor" },
        { "_<esc>_", "exit" },
    }

    local third = math.ceil(#buttons / 3)
    local row1, row2, row3 = {}, {}, {}

    for i = 1, third do
        table.insert(row1, buttons[i])
    end
    for i = third + 1, third * 2 do
        table.insert(row2, buttons[i])
    end
    for i = third * 2 + 1, #buttons do
        table.insert(row3, buttons[i])
    end

    local max_key_widths = {}
    local max_widths = {}
    for i = 1, third do
        local k1 = #row1[i][1]
        local k2 = row2[i] and #row2[i][1] or 0
        local k3 = row3[i] and #row3[i][1] or 0
        max_key_widths[i] = math.max(k1, k2, k3)

        local w1 = max_key_widths[i] + 4 + #row1[i][2]  -- 4 = " :: "
        local w2 = row2[i] and (max_key_widths[i] + 4 + #row2[i][2]) or 0
        local w3 = row3[i] and (max_key_widths[i] + 4 + #row3[i][2]) or 0
        max_widths[i] = math.max(w1, w2, w3)
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
    local line3 = format_row(row3)

    local hint = "^ " .. line1 .. " ^\n" ..
        "^ " .. line2 .. " ^\n" ..
        "^ " .. line3 .. " ^"

    debug_hydra = require("hydra")({
        hint = hint,
        config = {
            color = "pink",
            on_enter = function ()
                vim.g.debug_mode = true
            end,
            on_exit = function ()
                vim.g.debug_mode = nil
            end,
            hint = {
                type = "window",
                position = "top"
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
            { "c", run_or_continue, { silent = true } },
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
