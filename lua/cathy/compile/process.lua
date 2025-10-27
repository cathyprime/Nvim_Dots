local banner_proto = [[-*- Compilation_Mode; Starting_Directory :: %s -*-
Compilation started at %s]]

local Process = {}
Process.__index = Process

function Process:create_buf(name)

    self.buf = require("cathy.compile.buffer").new(name)
    local e = require("cathy.compile.errors").new()
    e:attach(self.buf.bufid)

    self.buf:register_keymap("n", "q", function ()
        vim.cmd [[close]]
    end)

    self.buf:register_keymap("n", "<c-c>", function ()
        if self.is_running then
            self:kill()
        end
    end)

    self.buf:register_keymap("n", "<cr>", function()
        local item = e[vim.fn.line(".")]
        if not item then return end
        local prev_win = vim.fn.win_getid(vim.fn.winnr('#'))

        vim.api.nvim_win_set_buf(prev_win, item.bufnr)
        vim.api.nvim_win_set_cursor(prev_win, { item.lnum, item.col - 1 or 0 })
        vim.api.nvim_set_current_win(prev_win)
    end)

    self.buf:register_keymap("n", "R", function ()
        if self.is_running then
            return
        end
        e:clear()
        self.buf:replace_lines(0, - 1, {})
        self.buf._ends_with_newline = false
        require("cathy.compile.highlights").clear_ns(self.buf.bufid)
        self:start(vim.b[self.buf.bufid].executor, vim.b[self.buf.bufid].exec_opts)
    end)
end

function Process.new()
    return setmetatable({}, Process)
end

function Process:start(executor, opts)
    vim.validate("executor",      executor,      "string")
    vim.validate("opts",          opts,          "table" )
    vim.validate("opts.cmd",      opts.cmd,      "string")
    vim.validate("opts.cwd",      opts.cwd,      "string",   true)
    vim.validate("opts.write_cb", opts.write_cb, "function", true)
    vim.validate("opts.exit_cb",  opts.exit_cb,  "function", true)

    local banner = string.format(
        banner_proto,
        vim.uv.cwd():gsub(os.getenv "HOME", "~"),
        os.date "%a %b %d %H:%M:%S"
    )
    local name = "Compile://" .. opts.cmd
    self:create_buf(name)

    self.buf:append_data(banner)
    self.buf:append_lines({ "", opts.cmd })
    local highlights = require("cathy.compile.highlights")
    local line = self.buf:pos("$")[2]
    vim.hl.range(
        self.buf.bufid,
        highlights.ns,
        highlights.hl_group.underline,
        { line, 0 },
        { line, -1 },
        { inclusive = true }
    )
    vim.hl.range(
        self.buf.bufid,
        highlights.ns,
        "DiagnosticFloatingInfo",
        { line, 0 },
        { line, -1 },
        { inclusive = true }
    )

    self.start_time = vim.uv.hrtime()
    opts = vim.tbl_deep_extend("force", {
        cwd = vim.uv.cwd(),
        write_cb = vim.schedule_wrap(function (err, data)
            assert(not err, err)
            if data then
                self.buf:append_data(data)
            end
        end),
        exit_cb = vim.schedule_wrap(function (obj)
            local exit_code
            if obj.signal and obj.signal ~= 0 then
                exit_code = 128 + obj.signal
            else
                exit_code = obj.code
            end
            if self.on_exit then
                self.on_exit(exit_code)
            end
            self.is_running = false
            local duration = (vim.uv.hrtime() - self.start_time) / 1e9
            local line, hl = require("cathy.compile.signalis")[exit_code](duration)
            self.buf:append_lines({ "", line })
            local linenr = self.buf:pos("$")[2]
            hl(self.buf.bufid, highlights.ns, linenr, highlights.get_group(exit_code))
            vim.api.nvim_exec_autocmds("User", {
                pattern = "CompileFinished",
            })
        end)
    }, opts)

    vim.b[self.buf.bufid].executor = executor
    vim.b[self.buf.bufid].exec_opts = opts
    self.is_running = true
    self:create_win()
    self._proc = require("cathy.compile.executor")[executor](opts)
end

function Process:kill()
    if self.is_running then
        self._proc:kill()
    end
end

function Process:create_win()
    if not self.buf then
        return
    end

    local win_exist = vim.iter(ipairs(vim.api.nvim_list_wins()))
        :any(function (_, winid)
            return vim.api.nvim_win_get_buf(winid) == self.buf.bufid
        end)

    if win_exist then
        return
    end

    local win = vim.api.nvim_open_win(self.buf.bufid, false, {
        split = "below",
        win = 0
    })

    vim.wo[win].spell = false
end

return Process
