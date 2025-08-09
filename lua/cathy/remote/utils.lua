local uv = vim.uv
local M = {}
local H = {}
local SSH = {}

M.error = {
    failed = 1,
    failed_password = 2,
}

H.info = vim.schedule_wrap(function (msg)
    vim.notify(msg, vim.log.levels.INFO)
end)
H.error = vim.schedule_wrap(function (msg)
    vim.notify(msg, vim.log.levels.ERROR)
end)

function H.nothing() end
function H.concat(tbl)
    return table.concat(tbl, "")
end
function H.split(str)
    return vim.split(str, " ", { plain = true, trimempty = true })
end

function H.pipe_close(pipe)
    uv.shutdown(pipe, function (err)
        assert(not err, err)
        uv.close(pipe)
    end)
end

function H.tbl_find(tbl, pred)
    if type(pred) ~= "function" then
        for index, value in ipairs(tbl) do
            if pred == value then return index end
        end
    else
        for index, value in ipairs(tbl) do
            if pred(value) then return index end
        end
    end
end

function H.mod_opts(ssh)
    if not H.tbl_find(ssh.args, "-T") and not H.tbl_find(ssh.args, "-t") then
        table.insert(ssh.args, 1, "-T")
    end

    local e_pos = H.tbl_find(ssh.args, "-E")
    if e_pos then
        ssh.logs = ssh.args[e_pos+1]
    else
        ssh.logs = vim.fn.tempname()
        table.insert(ssh.args, 1, "-E")
        table.insert(ssh.args, 2, ssh.logs)
    end
    return ssh
end

function SSH.new(connection)
    local obj = setmetatable({}, { __index = SSH })
    if type(connection) == "string" then
        obj.connection = connection
        obj.args = H.split(connection)
    elseif type(connection) == "table" then
        obj.connection = connection
        obj.args = connection
    end
    return H.mod_opts(obj)
end

function SSH:connect()
    H.info("Connecting...")
    vim.system({ "mkfifo", self.logs }, { detach = true }, H.nothing)
    local ssh do
        local h = io.popen("which ssh")
        ssh = h:read("*a"):gsub("[\n\r]+", "")
        h:close()
    end

    self.stdio = {
        uv.new_pipe(),
        uv.new_pipe(),
        uv.new_pipe()
    }

    local on_exit = function (code)
        H.info("Exited with code :: " .. code)
        self.handle = nil
        self.pid = nil
    end
    self.handle, self.pid = uv.spawn(ssh, {
        args = self.args,
        stdio = self.stdio
    }, on_exit)

    self.logs_pipe = uv.new_pipe()
    self.logs_pipe:open(uv.fs_open(self.logs, "r", 438))

    uv.read_start(self.stdio[2], function(err, data)
        assert(not err, err)
        if data then
            H.info(data)
        else
            if not self.stdio[2]:is_closing() then
                self.stdio[2]:close()
            end
        end
    end)
    uv.read_start(self.stdio[3], function(err, data)
        assert(not err, err)
        if data then
            H.info(data)
        else
            if not self.stdio[3]:is_closing() then
                self.stdio[3]:close()
            end
        end
    end)
    uv.read_start(self.logs_pipe, function(err, data)
        assert(not err, err)
        if data then
            if data:find "Permission denied.*password" then
                H.error("Password is not supported")
                return
            end
            H.info("FIFO :: " .. data)
        else
            if not self.logs_pipe:is_closing() then
                self.logs_pipe:close()
            end
        end
    end)

    vim.g.remote = function ()
        return self
    end
    return self
end

function SSH:send(cmd)
    self.stdio[1]:write(cmd .. "\n")
end

function SSH:close()
    H.info("Disconnecting...")
    vim.g.remote = nil
    if self.handle then
        uv.process_kill(self.handle, "SIGTERM")
    end
    vim.system({ "rm", self.logs }, { detach = true }, H.nothing)
end

SSH.new("Juno"):connect()

M.SSH = SSH
return M
