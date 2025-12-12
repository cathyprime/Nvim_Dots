local cache = {
    netcoredbg_dll_path = "",
    netcoredbg_args = "",
}

local function file_picker(prompt)
    return function ()
        local item = require("cathy.utils.mini.locpick.blocking") {
            prompt = prompt
        }
        if not item then
            return
        end
        return item.path
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
            args = { "--quiet", "--interpreter=dap" }
        }
    },
    configurations = {
        csharp = {
            {
                type = "coreclr",
                name = "launch - netcoredbg",
                request = "launch",
                program = file_picker " Path to dll :: ",
                args = function()
                    if cache.netcoredbg_args then
                        local args_string = vim.fn.input("Program arguments: ", cache.netcoredbg_args)
                        cache.netcoredbg_args = args_string
                        return vim.split(args_string, " +")
                    else
                        local args_string = vim.fn.input("Program arguments: ")
                        cache.netcoredbg_args = args_string
                        return vim.split(args_string, " +")
                    end
                end
            },
        },
        cpp = {
            {
                name = "GDB: Launch",
                type = "gdb",
                request = "launch",
                program = file_picker " Path to executable :: ",
                args = {}
            },
            {
                name = "LLDB: Launch",
                type = "codelldb",
                request = "launch",
                program = file_picker " Path to executable :: ",
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
                args = {},
                console = "integratedTerminal",
            },
            {
                name = "LLDB: Launch (args)",
                type = "codelldb",
                request = "launch",
                program = file_picker " Path to executable :: ",
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
                args = function()
                    return vim.split(vim.fn.input("Args: "), " +", { trimempty = true })
                end,
                console = "integratedTerminal",
            }
        }
    }
}

config.configurations.c = config.configurations.cpp

return config
