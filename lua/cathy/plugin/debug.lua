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
    {
        elements = {
            { id = "watches", size = 0.30},
            { id = "console", size = 0.55 },
            { id = "breakpoints", size = 0.15 },
        },
        size = 40,
        position = "left",
    },
    make_simple_layout {
        left = "watches",
        right = "console"
    },
    make_simple_layout {
        left = "scopes",
        right = "stacks",
    },
}

local clamp = function (idx)
    return ((idx - 2) % (#layouts - 1)) + 2
end

local indexer = {
    current = 2,
    next = function (self)
        self.current = clamp(self.current + 1)
        return self.current
    end,
    prev = function (self)
        self.current = clamp(self.current - 1)
        return self.current
    end
}

return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "nvimtools/hydra.nvim",
    },
    keys = { { "<leader>z" } },
    config = function()
        local dap   = require("dap")
        local dapui = require("dapui")
        ---@diagnostic disable-next-line: different-requires
        dap.configurations = require("cathy.config.dap").configurations
        ---@diagnostic disable-next-line: different-requires
        dap.adapaters      = require("cathy.config.dap").adapaters

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
 _n_: step over   _J_: to cursor  _<cr>_: Breakpoint
 _i_: step into   _X_: Quit        _B_: Condition breakpoint ^
 _o_: step out    _K_: Float       _L_: Log breakpoint
 _b_: step back   _W_: Watch       _u_: Toggle additional UI
         _\^_: Prev layout     _$_: Next layout
 ^ ^            ^                 ^  ^
 ^ ^ _C_: Continue/Start          ^  ^   Change window
 ^ ^ _R_: Reverse continue        ^  ^       _<c-k>_^
 ^ ^            ^                 ^  _<c-h>_ ^     ^ _<c-l>_
 ^ ^     _<esc>_: exit            ^  ^       _<c-j>_^
 ^ ^            ^
]]

        local debug_hydra = require("hydra")({
            hint = hint,
            config = {
                color = "pink",
                hint = {
                    position = "middle-right",
                    float_opts = {
                        border = "rounded",
                    }
                },
            },
            name = "dap",
            mode = { "n", "x" },
            heads = {
                { "<cr>", function() dap.toggle_breakpoint() end, { silent = true } },
                { "B", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { silent = true }},
                { "L", function()
                    vim.ui.input({ prompt = "Log point message: " }, function(input)
                        dap.set_breakpoint(nil, nil, input)
                    end)
                end, { silent = false } },
                { "i", function() dap.step_into() end, { silent = false } },
                { "n", function() dap.step_over() end, { silent = false } },
                { "o", function() dap.step_out() end, { silent = false } },
                { "b", function() dap.step_back() end, { silent = false } },
                { "R", function() dap.reverse_continue() end, { silent = false } },
                { "W", function() dapui.elements.watches.add(vim.fn.expand("<cword>")) end, { silent = false } },
                { "^", function ()
                    local ok, _ = pcall(dapui.toggle, { layout = indexer.current })
                    if not ok then
                        vim.notify("no active session", vim.log.levels.INFO)
                        return
                    end
                    dapui.open({ layout = indexer:prev() })
                end },
                { "$", function ()
                    local ok, _ = pcall(dapui.toggle, { layout = indexer.current })
                    if not ok then
                        vim.notify("no active session", vim.log.levels.INFO)
                        return
                    end
                    dapui.open({ layout = indexer:next() })
                end },
                { "u", function()
                    local ok, _ = pcall(dapui.toggle, { layout = 1 })
                    if not ok then
                        vim.notify("no active session", vim.log.levels.INFO)
                    end
                end, { silent = false } },
                { "C", function() dap.continue() end, { silent = false } },
                { "K", function()
                    dapui.float_element(nil, {
                        width = 100,
                        height = 30,
                        position = "center",
                        enter = true
                    })
                end, { silent = false } },
                { "J", function() dap.run_to_cursor() end, { silent = false } },
                { "X", function() dap.disconnect({ terminateDebuggee = false }) end, { silent = false } },
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
    end
}
