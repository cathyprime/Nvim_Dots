local utils = require("cathy.remote.utils")
vim.g.remote_connected_hostname = nil

vim.api.nvim_create_user_command("Remote",
    function (opts)
        if vim.g.remote_connected_hostname and utils.is_mounted(vim.g.remote_connected_hostname) then
            utils.disconnect(vim.g.remote_connected_hostname, function ()
                vim.g.remote_connected_hostname = nil
            end)
            return
        end

        local connect = function (hostname)
            if not hostname then
                return
            end

            local on_connect = function ()
                vim.g.remote_connected_hostname = hostname
                local path = utils.get_path(hostname)
                vim.cmd.cd(path)
                vim.cmd("Oil " .. path)
            end

            if utils.is_mounted(hostname) then
                on_connect()
            else
                utils.connect(hostname, vim.schedule_wrap(on_connect))
            end
        end
        if opts.args ~= "" then
            connect(opts.args)
            return
        end
        vim.ui.select(utils.get_hosts(), { prompt = "Connect to host" }, connect)
    end,
    {
        force = true,
        nargs = "?",
    }
)
