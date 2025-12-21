local cache = {
    netcoredbg_dll_path = "",
    netcoredbg_args = "",
    gdb_args = "",
}

local function file_picker(prompt)
    return function (cb)
        local item = require("cathy.utils.mini.locpick") {
            prompt = prompt,
            cb = cb
        }
    end
end

local config = {
    adapters = {
        netcoredbg = {
            type = "executable",
            command = "netcoredbg",
            args = { "--interpreter=vscode" }
        },
        codelldb = {
            type = "server",
            port = "${port}",
            executable = {
                command = "codelldb",
                args = { "--port", "${port}" }
            }
        },
        gdb = {
            type = "executable",
            command = "gdb",
            args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
        }
    },
    configurations = {
        csharp = {
            {
                type = "coreclr",
                name = "launch - netcoredbg",
                request = "launch",
                program = file_picker " Path to dll :: ",
                args = function(cb)
                    local input = vim.fn.input({
                        prompt = "Program Args: ",
                        default = cache.netcoredbg_args,
                    })
                    cache.netcoredbg_args = input
                    cb(vim.split(input, " +", { trimempty = true }))
                end
            },
        },
        cpp = {
            {
                name = "GDB: Launch",
                type = "gdb",
                request = "launch",
                program = file_picker " Path to executable :: ",
                args = {},
            },
            {
                name = "GDB: Launch (args)",
                type = "gdb",
                request = "launch",
                program = file_picker " Path to executable :: ",
                args = function(cb)
                    local input = vim.fn.input({
                        prompt = "Program Args: ",
                        default = cache.gdb_args,
                    })
                    cache.gdb_args = input
                    cb(vim.split(input, " +", { trimempty = true }))
                end,
            },
            {
                name = "LLDB: Launch",
                type = "codelldb",
                request = "launch",
                program = file_picker " Path to executable :: ",
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
                console = "integratedTerminal",
                args = {},
            },
            {
                name = "LLDB: Launch (args)",
                type = "codelldb",
                request = "launch",
                program = file_picker " Path to executable :: ",
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
                args = function(cb)
                    local input = vim.fn.input({
                        prompt = "Program Args: ",
                        default = cache.gdb_args,
                    })
                    cache.gdb_args = input
                    cb(vim.split(input, " +", { trimempty = true }))
                end,
                console = "integratedTerminal",
            }
        }
    }
}

config.configurations.c = config.configurations.cpp

return config
