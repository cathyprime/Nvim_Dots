local home_dir = os.getenv("HOME")
local remote_group = vim.api.nvim_create_augroup("Magda_Remote", { clear = true })
vim.g.remote_path = nil

local get_ssh_cmd = function (remote_command, dir, hostname)
    if not vim.g.remote_connected_hostname and not hostname then
        return nil
    end
    local opt = function (option)
        return { "-o", option }
    end
    local func_name = "remote"
    local shell_expr

    if not remote_command and not dir then
        shell_expr = nil
    elseif remote_command then
        shell_expr = (dir and ("cd '" .. dir .. "' && " .. remote_command)) or "$@"
    else
        shell_expr = (dir and ("cd '" .. dir .. "' && exec \\$SHELL -l")) or "exec \\$SHELL -l"
    end

    if shell_expr then
        shell_expr = [["]] .. shell_expr .. [[";]]
    end

    local ssh = {
        "()", "{",
        "ssh",
        opt "BatchMode=yes",
        opt "ControlMaster=auto",
        opt "ControlPersist=60",
        opt [[ControlPath=/tmp/ssh/control:\%h:\%p:\%r]],
    }
    if shell_expr and shell_expr:find("SHELL") then
        table.insert(ssh, "-t")
    end

    table.insert(ssh, vim.g.remote_connected_hostname or hostname)
    if shell_expr then
        table.insert(ssh, shell_expr)
    end
    table.insert(ssh, "};")
    table.insert(ssh, func_name)

    table.insert(ssh, remote_command)
    return vim.iter(ssh):flatten():fold(func_name, function (acc, p)
        return acc .. " " .. p
    end)
end

local get_remote_home = function (hostname)
    local ssh = get_ssh_cmd("echo $HOME", nil, hostname)
    local stdout = vim.system({ "bash", "-c", ssh }, { stdout = true }):wait().stdout
    return (stdout:gsub("\n", ""))
end

local log = {
    info = vim.schedule_wrap(function (msg)
        vim.notify(msg, vim.log.levels.INFO)
    end),
    err = vim.schedule_wrap(function (msg)
        vim.notify(msg, vim.log.levels.ERROR)
    end)
}

local create_if_not_exists = function (path)
    if not vim.uv.fs_stat(path) then
        vim.schedule(function ()
            vim.fn.mkdir(path, "p")
        end)
    end
    return path
end

local get_sshfs_path_or_create = function (hostname)
    return create_if_not_exists(home_dir .. "/.sshfs/" .. hostname)
end

local ControlPath = function (escape)
    if escape then
        return [[ControlPath=/tmp/ssh/control:\%h:\%p:\%r]]
    end
    return [[ControlPath=/tmp/ssh/control:%h:%p:%r]]
end

local cmd = {
    sshfs = function (tbl)
        tbl.path = tbl.path or ""
        create_if_not_exists("/tmp/ssh/")
        local sshfs = {
            "sshfs",
            "-o", "ControlMaster=auto",
            "-o", "ControlPersist=60",
            "-o", "dir_cache=yes",
            "-o", ControlPath(tbl.escape),
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
        :filter(function (tokens)
            return tokens[1] == hostname
        end)
        :take(1)

    local next = defaults:next()
    if not next then
        return
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

local get_path = function (hostname, cb)
    local f = function (path)
        if not path then
            return
        end
        save_default(hostname, path)
        cb(path)
    end

    vim.schedule(function ()
        vim.ui.input({
            prompt = hostname .. " path to mount :: ",
            default = get_default(hostname),
        }, f)
    end)
end

local mount = function (tbl)
    tbl.opts = { detach = true }

    if tbl.with_pass then
        local password = vim.fn.inputsecret("Enter password for " .. tbl.hostname .. " :: ")
        if password and password ~= "" then
            tbl.opts = { stdin = password }
        else
            return
        end
    end

    local on_path = vim.schedule_wrap(function (path)
        tbl.path = path
        tbl.cmd = cmd.sshfs(tbl)
        log.info("Trying to mount...")
        local f = vim.schedule_wrap(function (result)
            if result.code == 0 then
                log.info("Mounted host: " .. tbl.hostname)
                if tbl.cb then tbl.cb() end
                vim.g.remote_path = tbl.path ~= "" and tbl.path or get_remote_home(tbl.hostname)
                vim.g.remote_connected_hostname = tbl.hostname
                return
            end
            log.err("Failed mounting " .. tbl.hostname)
            log.err(result.stderr)
        end)
        vim.system(tbl.cmd, tbl.opts, f)
    end)

    if not tbl.path then
        get_path(tbl.hostname, on_path)
    else
        on_path(tbl.path)
    end
end

local in_term = function(hostname, cb)
    local cmd = table.concat(cmd.sshfs { hostname = hostname, escape = true }, " ")
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

local is_mounted = function (hostname)
    local path = get_sshfs_path_or_create(hostname)
    local mountpoint = vim.system({ "mountpoint", "-q", path }, {}):wait()
    return mountpoint.code == 0 -- 0 = mountpoint, 32 = not a mountpoint
end

local disconnect = function (hostname, cb)
    vim.api.nvim_clear_autocmds({ group = remote_group })
    local cmd = {
        "fusermount3",
        "-u",
        get_sshfs_path_or_create(hostname)
    }
    if vim.uv.cwd():find(home_dir .. "/.sshfs") then
        vim.cmd("silent cd")
    end
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

local connect = function (hostname, path, cb)
    if path then
        save_default(hostname, path)
    end
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = remote_group,
        pattern = "*",
        callback = function ()
            disconnect(hostname)
        end
    })
    if is_mounted(hostname) then
        vim.g.remote_connected_hostname = hostname
        vim.system(
            { "findmnt", "-no", "SOURCE", "-t", "fuse.sshfs" },
            { detach = true },
            function (obj)
                local lines = vim.split(obj.stdout, "\n", { trimempty = true, plain = true })
                local mounts = vim.iter(lines)
                    :map(function (line)
                        return vim.split(line, ":", { trimempty = true, plain = true })
                    end)
                    :filter(function (entry)
                        return entry[1] == hostname
                    end)
                    :take(1)
                local next = mounts:next()
                if next then
                    vim.g.remote_path = next[2]
                    vim.schedule(function ()
                        local path = get_sshfs_path_or_create(hostname)
                        vim.cmd("silent cd " .. path)
                        vim.cmd.e(path)
                    end)
                end
            end
        )
        log.info("Connecting to mounted filesystem")
        return
    end
    log.info("Connecting to: " .. hostname)
    vim.system(cmd.ssh(hostname), {}, function (result)
        if result.code == 0 then
            mount {
                hostname = hostname,
                path = path,
                cb = cb,
            }
            return
        end

        if result.stderr:match("Permission denied") then
            vim.schedule(function ()
                mount {
                    hostname = hostname,
                    with_pass = true,
                    path = path,
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

local get_hosts = function ()
    local ssh_conf = home_dir .. "/.ssh/config"

    if not vim.uv.fs_stat(ssh_conf) then
        error "no ssh config"
    end

    local file = assert(io.open(ssh_conf))
    return vim.iter(file:lines())
        :filter(function (line)
            return line:find "Host%s+" and not line:find "Host%s+%*"
        end)
        :map(function (line)
            return (line:gsub("Host%s+", ""))
        end)
        :totable()
end

local choose_host = function (cb)
    local names = get_hosts()

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
    choose_host = choose_host,
    get_hosts = get_hosts,
    connect = connect,
    disconnect = disconnect,
    is_mounted = is_mounted,
    get_ssh_cmd = get_ssh_cmd,
    local_to_remote_path = function (path)
        if not vim.g.remote_connected_hostname then
            return path
        end

        local mount_path = get_sshfs_path_or_create(vim.g.remote_connected_hostname)
        if not vim.startswith(path, mount_path) then
            return path
        end

        local rel_path = string.sub(path, #mount_path + 1)
        if rel_path:sub(1, 1) == "/" then
            rel_path = rel_path:sub(2)
        end

        return vim.g.remote_path .. "/" .. rel_path
    end
}
