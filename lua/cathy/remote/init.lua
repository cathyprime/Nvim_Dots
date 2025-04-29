local utils = require("cathy.remote.utils")
vim.g.remote_connected_hostname = nil
vim.g.remote_path = nil

vim.api.nvim_create_user_command("Remote",
    function (opts)
        if vim.g.remote_connected_hostname and utils.is_mounted(vim.g.remote_connected_hostname) then
            utils.disconnect(vim.g.remote_connected_hostname)
            return
        end

        local connect = function (hostname)
            local on_connect = function ()
                local path = utils.get_path(hostname)
                vim.cmd.cd(path)
                vim.cmd("e " .. path)
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

        utils.get_hosts(connect)
    end,
    {
        force = true,
        nargs = "?",
    }
)
