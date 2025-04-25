local cache = {
    netcoredbg_dll_path = "",
    netcoredbg_args = "",
}

return {
    adapaters = {
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
        }
    },
    configurations = {
        csharp = {
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
        },
        cpp = {
            {
                name = "LLDB: Launch",
                type = "codelldb",
                request = "launch",
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
                args = {},
                console = "integratedTerminal",
            },
            {
                name = "LLDB: Launch (args)",
                type = "codelldb",
                request = "launch",
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
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
