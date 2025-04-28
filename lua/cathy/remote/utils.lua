local home_dir = os.getenv("HOME")

local info = function (msg)
    vim.notify(msg, vim.log.levels.INFO)
end

local err = function (msg)
    vim.notify(msg, vim.log.levels.ERROR)
end

local get_hosts = function ()
    local ssh_conf = home_dir .. "/.ssh/config"

    if not vim.uv.fs_stat(ssh_conf) then
        error "no ssh config"
    end

    local file = io.open(ssh_conf)
    local names = vim.iter(assert(file):lines())
        :filter(function (line)
            return line:find "Host%s+" and not line:find "Host%s+%*"
        end)
        :map(function (line)
            return (line:gsub("Host%s+", ""))
        end)
        :totable()

    return names
end

local create_if_not_exists = function (path)
    if not vim.uv.fs_stat(path) then
        vim.uv.fs_mkdir(path, tonumber("755", 8))
    end
end

local get_sshfs_path_or_create = function (hostname)
    local path = home_dir .. "/.sshfs/" .. hostname
    create_if_not_exists(path)
    return path
end

local mount_with_sshfs = function (hostname, cb)
    local cmd = {
        "sshfs",
        hostname .. ":",
        get_sshfs_path_or_create(hostname)
    }

    local opts = { detach = true }

    vim.system(cmd, opts, function (result)
        if result.code == 0 then
            info("Connected to host: " .. hostname)
            if cb then cb() end
            return
        end
        err("Failed to connect to " .. hostname)
        err(result.stderr)
    end)
end

local mount_with_password = function(hostname, cb)
    local password = vim.fn.inputsecret("Enter password for " .. hostname .. ": ")

    if password and password ~= "" then
        local cmd = {
            "sshfs",
            "-o", "password_stdin",
            hostname .. ":",
            get_sshfs_path_or_create(hostname),
        }

        local stdin = {
            password
        }

        vim.system(cmd, { stdin = stdin }, function(result)
            if result.code == 0 then
                info("Connected to host: " .. hostname)
                if cb then cb() end
            else
                err("Failed to connect to " .. hostname)
                err(result.stderr)
            end
        end)
    end
end

local test_connection = function (hostname, cb)
    local test_cmd = {
        "ssh",
        "-o", "BatchMode=yes",
        "-o", "ConnectTimeout=5",
        "-o", "StrictHostKeyChecking=accept-new",
        hostname,
    }
    vim.system(test_cmd, {}, cb)
end

local in_term = function(hostname, cb)
    local cmd = table.concat({
        "sshfs",
        hostname..":",
        get_sshfs_path_or_create(hostname)
    }, " ")
    local bufnr = vim.api.nvim_create_buf(false, true)
    local size = 0.50

    local columns = vim.opt.columns:get()
    local lines   = vim.opt.lines:get()
    local i_size  = (1 - size) / 2

    local height = math.floor(lines   * size)
    local width  = math.floor(columns * size)
    local row    = math.floor(lines   * i_size)
    local col    = math.floor(columns * i_size)

    vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "single",
    })
    vim.cmd.term(cmd)
    vim.api.nvim_create_autocmd("TermClose", {
        once = true,
        buffer = vim.api.nvim_get_current_buf(),
        callback = function ()
            if vim.v.event.status == 0 then
                info("Connected to host: " .. hostname)
                vim.cmd("bd!")
                if cb then cb() end
                return
            end
            vim.cmd("bd!")
            err("Failed to connect to " .. hostname)
        end
    })
    vim.cmd.startinsert()
end

local connect = function (hostname, cb)
    test_connection(hostname, function (result)
        if result.code == 0 then
            mount_with_sshfs(hostname)
            if cb then cb() end
            return
        end

        if result.stderr:match("Permission denied") then
            vim.schedule(function ()
                mount_with_password(hostname, cb)
            end)
        else
            vim.schedule(function ()
                in_term(hostname, cb)
            end)
        end
    end)
end

local disconnect = function (hostname, cb)
    local cmd = {
        "fusermount3",
        "-u",
        get_sshfs_path_or_create(hostname)
    }
    vim.system(cmd, { detach = true }, function (result)
        if result.code == 0 then
            info("Disconnected from host: " .. hostname)
            if cb then cb() end
            return
        end
        err("Failed to disconnect from host " .. hostname)
        err(result.stderr)
    end)
end

local is_mounted = function (hostname)
    local path = get_sshfs_path_or_create(hostname)
    local mountpoint = vim.system({ "mountpoint", "-q", path }, {}):wait()
    return mountpoint.code == 0 -- 0 = mountpoint, 32 = not a mountpoint
end

return {
    get_path = get_sshfs_path_or_create,
    get_hosts = get_hosts,
    connect = connect,
    disconnect = disconnect,
    is_mounted = is_mounted
}
