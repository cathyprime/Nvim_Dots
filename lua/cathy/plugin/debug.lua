vim.g.termdebug_config = {
    wide = 1,
    useFloatingHover = 0,
}

local termdebug = vim.api.nvim_create_augroup("TermDebug", {})

local cache = {
    netcoredbg_dll_path = "",
    netcoredbg_args = "",
}

local gdb_filetypes = {
    "rust",
    "c",
    "cpp",
}

local function isGDBFiletype(ft)
    if ft == "" then return true end
    return vim.iter(gdb_filetypes):any(function(v)
        return ft:match(v)
    end)
end

return {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
        "williamboman/mason.nvim",
        "mfussenegger/nvim-dap",
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
    },
    keys = { { "<leader>z" } },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")
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

        ---@diagnostic disable-next-line
        dapui.setup({
            layouts = {
                {
                    -- Left side layout
                    elements = {
                        { id = "stacks", size = 0.33 },
                        { id = "console", size = 0.33 },
                        { id = "repl", size = 0.33 },
                    },
                    size = 40, -- Width of the window
                    position = "left",
                },
                {
                    -- Bottom layout
                    elements = {
                        { id = "scopes", size = 0.50 },
                        { id = "watches", size = 0.50 },
                    },
                    size = 10, -- Height of the window
                    position = "bottom",
                },
            }}
        )

        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end

        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end

        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end

        local hint_termdebug = [[
 _<F1>_: Source _<F2>_: Gdb
 _<F3>_: Var    _<F4>_: Program ^
  _K_: Evaluate _<esc>_: exit
]]
        local termdebug_hydra = require("hydra")({
            hint = hint_termdebug,
            config = {
                color = "pink",
                hint = {
                    position = "top-right",
                    float_opts = {
                        border = "rounded",
                    }
                }
            },
            name = "termdebug",
            mode = { "n", "x" },
            heads = {
                { "<F1>", "<cmd>Source<cr>",  { silent = true } },
                { "<F2>", "<cmd>Gdb<cr>",     { silent = true } },
                { "<F3>", "<cmd>Var<cr>",     { silent = true } },
                { "<F4>", "<cmd>Program<cr>", { silent = true } },
                { "K", "<cmd>Evaluate<cr>",   { silent = true } },
                { "<esc>", nil,               { exit = true, silent = true } },
            }
        })
        local hint = [[
 _n_: step over   _J_: to cursor  _<cr>_: Breakpoint
 _i_: step into   _X_: Quit        _B_: Condition breakpoint ^
 _o_: step out    _K_: Hover       _L_: Log breakpoint
 _b_: step back   _u_: Toggle UI
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
                { "u", function()
                    local ok, _ = pcall(dapui.toggle)
                    if not ok then
                        vim.notify("no active session", vim.log.levels.INFO)
                    end
                end, { silent = false } },
                { "C", function() dap.continue() end, { silent = false } },
                { "K", function() require("dap.ui.widgets").hover() end, { silent = false } },
                { "J", function() dap.run_to_cursor() end, { silent = false } },
                { "X", function() dap.disconnect({ terminateDebuggee = false }) end, { silent = false } },
                { "<c-h>", "<c-w><c-h>", { silent = true } },
                { "<c-j>", "<c-w><c-j>", { silent = true } },
                { "<c-k>", "<c-w><c-k>", { silent = true } },
                { "<c-l>", "<c-w><c-l>", { silent = true } },
                { "<esc>", "<cmd>let g:debug_mode = v:false<cr>", { exit = true,  silent = true } },
            }
        })

        local function map_hydra(key, bufnr)
            bufnr = bufnr
            vim.keymap.set("n", key, function()
                termdebug_hydra:activate()
            end, { buffer = bufnr })
        end

        local function unmap_hydra(key, bufnr)
            vim.keymap.del("n", key, { buffer = bufnr })
        end

        local function set_autocmds_for_termdebug()
            local hydra_bufnr
            vim.api.nvim_create_autocmd("User", {
                pattern = "TermdebugStartPre",
                group = termdebug,
                callback = function(ev)
                    hydra_bufnr = ev.buf
                    map_hydra("<F1>", hydra_bufnr)
                    map_hydra("<F2>", hydra_bufnr)
                    map_hydra("<F3>", hydra_bufnr)
                    map_hydra("<F4>", hydra_bufnr)
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "TermdebugStartPost",
                group = termdebug,
                callback = function()
                    vim.cmd("Var")
                    vim.api.nvim_win_set_height(0, 5)
                    vim.cmd("set winfixheight")
                    vim.cmd("set winfixbuf")
                    vim.schedule(function()
                        vim.cmd("Source")
                    end)
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "TermdebugStopPost",
                group = termdebug,
                callback = function()
                    vim.g.debug_mode = false
                    vim.schedule(function()
                        -- termdebug_hydra:exit() -- <- this does not clean the pink keymaps AT ALL
                        termdebug_hydra.layer:exit()
                        unmap_hydra("<F1>", hydra_bufnr)
                        unmap_hydra("<F2>", hydra_bufnr)
                        unmap_hydra("<F3>", hydra_bufnr)
                        unmap_hydra("<F4>", hydra_bufnr)
                    end)
                end,
            })
        end

        vim.keymap.set("n", "<leader>z", function()
            vim.g.debug_mode = true
            if require("zen-mode.view").is_open() then
                require("zen-mode").close()
            end
            if isGDBFiletype(vim.o.filetype) then
                set_autocmds_for_termdebug()
                if vim.b.termdebug_command then
                    vim.cmd(vim.b.termdebug_command)
                else
                    vim.cmd("Termdebug")
                end
                termdebug_hydra:activate()
            else
                debug_hydra:activate()
            end
        end)

        vim.fn.sign_define("DapBreakpoint", { text="", texthl="Error", linehl="", numhl="" })
    end
}
