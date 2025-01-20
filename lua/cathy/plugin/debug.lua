local cache = {
    netcoredbg_dll_path = "",
    netcoredbg_args = "",
}

return {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
        "williamboman/mason.nvim",
        "mfussenegger/nvim-dap",
        "igorlfs/nvim-dap-view",
        "nvim-neotest/nvim-nio",
    },
    keys = { { "<leader>z" } },
    config = function()
        local dap = require("dap")
        require("mason-nvim-dap").setup({
            ensure_installed = {
                "debugpy",
                "netcoredbg"
            },
            automatic_installation = true,
            handlers = {
                function(config)
                    require("mason-nvim-dap").default_setup(config)
                end,
                 coreclr = function(config)
                    config.adapters = {
                        type = 'executable',
                        command = require("mason-core.path").package_prefix("netcoredbg") .. "/netcoredbg",
                        args = {'--interpreter=vscode'}
                    }
                    config.configurations = {
                        {
                            type = "coreclr",
                            name = "launch - netcoredbg",
                            request = "launch",
                            program = function()
                                if cache.netcoredbg_dll_path then
                                    local input = vim.fn.input("Path to dll ", cache.netcoredbg_dll_path, "file")
                                    cache.netcoredbg_dll_path = input
                                    return input
                                else
                                    local input = vim.fn.input("Path to dll ", vim.fn.getcwd() .. "/bin/Debug/", "file")
                                    cache.netcoredbg_dll_path = input
                                    return input
                                end
                            end,
                            args = function()
                                if cache.netcoredbg_args then
                                    local args_string = vim.fn.input("Arguments: ", cache.netcoredbg_args)
                                    cache.netcoredbg_args = args_string
                                    return vim.split(args_string, " +")
                                else
                                    local args_string = vim.fn.input("Arguments: ")
                                    cache.netcoredbg_args = args_string
                                    return vim.split(args_string, " +")
                                end
                            end
                        },
                    }
                    require("mason-nvim-dap").default_setup(config)
                end
            },
        })

        local hint = [[
 _n_: step over   _J_: to cursor  _<cr>_: Breakpoint
 _i_: step into   _X_: Quit        _u_: Toggle UI     ^
 _o_: step out    _K_: Hover       _L_: Log breakpoint
 _b_: step back   _W_: Watch
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
                { "u", "<cmd>DapViewToggle<cr>" },
                { "W", "<cmd>DapViewWatch<cr>" },
                { "C", function() dap.continue() end, { silent = false } },
                { "K", function() require("dap.ui.widgets").hover() end, { silent = false } },
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
            if require("zen-mode.view").is_open() then
                require("zen-mode").close()
            end
            debug_hydra:activate()
        end)

        vim.fn.sign_define("DapBreakpoint", { text="", texthl="Error", linehl="", numhl="" })
    end
}
