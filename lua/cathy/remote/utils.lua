local home_dir = os.getenv("HOME")
vim.g.remote_path = nil

local log = {
    info = function (msg)
        vim.notify(msg, vim.log.levels.INFO)
    end,
    err = function (msg)
        vim.notify(msg, vim.log.levels.ERROR)
    end
}

local create_if_not_exists = function (path)
    if not vim.uv.fs_stat(path) then
        vim.fn.mkdir(path, { "p" })
    end
    return path
end

local get_sshfs_path_or_create = function (hostname)
    return create_if_not_exists(home_dir .. "/.sshfs/" .. hostname)
end

local cmd = {
    sshfs = function (tbl)
        tbl.path = tbl.path or ""
        create_if_not_exists("/tmp/ssh/")
        local sshfs = {
            "sshfs",
            "-o", "ControlMaster=auto",
            "-o", "ControlPersist=60",
            "-o", [[ControlPath=/tmp/ssh/control:%h:%p:%r]],
            tbl.hostname .. ":" .. tbl.path,
            get_sshfs_path_or_create(tbl.hostname)
        }
        if tbl.with_pass then
            table.insert(sshfs, 2, "password_stdin")
            table.insert(sshfs, 2, "-o")
        else
            table.insert(sshfs, 2, "BatchMode=yes")
            table.insert(sshfs, 2, "-o")
        end
        return sshfs
    end,
    ssh = function (hostname)
        local ssh = {
            "ssh",
            "-o", "BatchMode=yes",
            "-o", "ConnectTimeout=5",
            hostname,
        }
        return ssh
    end
}

local get_default = function (hostname)
    local state = create_if_not_exists(vim.fn.stdpath("state") .. "/remote")
    local file_name = state .. "/default_paths"
    if not vim.uv.fs_stat(file_name) then
        return ""
    end
    local file = assert(io.open(file_name))
    local defaults = vim.iter(file:lines())
        :map(function (line)
            local tokens = {}
            for token in string.gmatch(line, "[^%s]+") do
                table.insert(tokens, token)
            end
            return tokens
        end)
        :filter(function (tokens)
            return tokens[1] == hostname
        end)
        :take(1)

    local next = defaults:next()
    if not next then
        return ""
    end
    return next[2]
end

local save_default = function (hostname, path)
    local state = create_if_not_exists(vim.fn.stdpath("state") .. "/remote")
    local file_name = state .. "/default_paths"
    if not vim.uv.fs_stat(file_name) then
        vim.fn.writefile({ hostname .. "\t\t\t" .. path }, file_name)
        return
    end
    local file = assert(io.open(file_name))
    local defaults = vim.iter(file:lines())
        :map(function (line)
            local tokens = {}
            for token in string.gmatch(line, "[^%s]+") do
                table.insert(tokens, token)
            end
            return tokens
        end)
        :totable()

    if not vim.iter(defaults):any(function (default) return default[1] == hostname end) then
        table.insert(defaults, { hostname, path })
    end

    local lines = vim.iter(defaults)
        :map(function (default)
            if default[1] == hostname then
                default[2] = path
            end
            return table.concat(default, "\t\t\t")
        end)
        :totable()

    vim.fn.writefile(lines, file_name)
end

local get_path = function (hostname)
    local path = vim.fn.input {
        prompt = hostname .. " path to mount",
        default = get_default(hostname)
    }
    save_default(hostname, path)
    return path
end

local mount = function (tbl)
    tbl.opts = { detach = true }

    if tbl.with_pass then
        local password = vim.fn.inputsecret("Enter password for " .. tbl.hostname .. ": ")
        if password and password ~= "" then
            tbl.opts = { stdin = password }
        else
            return
        end
    end

    tbl.path = get_path(tbl.hostname)
    tbl.cmd = cmd.sshfs(tbl)

    vim.system(tbl.cmd, tbl.opts, function (result)
        if result.code == 0 then
            log.info("Connected to host: " .. tbl.hostname)
            if tbl.cb then tbl.cb() end
            vim.g.remote_path = tbl.path ~= "" and tbl.path or "~/"
            vim.g.remote_connected_hostname = tbl.hostname
            return
        end
        log.err("Failed to connect to " .. tbl.hostname)
        log.err(result.stderr)
    end)
end

local in_term = function(hostname, cb)
    local cmd = table.concat(cmd.sshfs { hostname = hostname }, " ")
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
                log.info("Connected to host: " .. hostname)
                vim.cmd("bd!")
                if cb then cb() end
                return
            end
            vim.cmd("bd!")
            log.err("Failed to connect to " .. hostname)
        end
    })
    vim.cmd.startinsert()
end

local connect = function (hostname, cb)
    vim.system(cmd.ssh(hostname), {}, function (result)
        if result.code == 0 then
            mount {
                hostname = hostname,
                cb = cb,
            }
            return
        end

        if result.stderr:match("Permission denied") then
            vim.schedule(function ()
                mount {
                    hostname = hostname,
                    with_pass = true,
                    cb = cb,
                }
            end)
            return
        end

        vim.schedule(function ()
            in_term(hostname, cb)
        end)
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
            log.info("Disconnected from host: " .. hostname)
            if cb then cb() end
            vim.g.remote_path = nil
            vim.g.remote_connected_hostname = nil
            return
        end
        log.err("Failed to disconnect from host " .. hostname)
        log.err(result.stderr)
    end)
end

local is_mounted = function (hostname)
    local path = get_sshfs_path_or_create(hostname)
    local mountpoint = vim.system({ "mountpoint", "-q", path }, {}):wait()
    return mountpoint.code == 0 -- 0 = mountpoint, 32 = not a mountpoint
end

local get_hosts = function (cb)
    local ssh_conf = home_dir .. "/.ssh/config"

    if not vim.uv.fs_stat(ssh_conf) then
        error "no ssh config"
    end

    local file = assert(io.open(ssh_conf))
    local names = vim.iter(file:lines())
        :filter(function (line)
            return line:find "Host%s+" and not line:find "Host%s+%*"
        end)
        :map(function (line)
            return (line:gsub("Host%s+", ""))
        end)
        :totable()

    table.insert(names, "Other...")

    vim.ui.select(names, { prompt = "Connect to host" }, function (hostname)
        if not hostname then
            return
        end
        if hostname == "Other..." then
            vim.ui.input({
                prompt = "Hostname:"
            }, cb)
            return
        end
        cb(hostname)
    end)
end

return {
    get_path = get_sshfs_path_or_create,
    get_hosts = get_hosts,
    connect = connect,
    disconnect = disconnect,
    is_mounted = is_mounted,
    get_ssh_cmd = function (remote_command)
        if not vim.g.remote_connected_hostname then
            return nil
        end
        local ssh = {
            "ssh",
            "-o", "BatchMode=yes",
            "-o", "ControlMaster=auto",
            "-o", "ControlPersist=60",
            "-o", [[ControlPath=/tmp/ssh/control:\%h:\%p:\%r]],
            vim.g.remote_connected_hostname
        }
        if remote_command then
            table.insert(ssh, "'" .. remote_command .. "'")
        end
        return table.concat(ssh, " ")
    end
}
