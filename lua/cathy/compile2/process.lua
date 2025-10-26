local banner_proto = [[-*- Compilation_Mode; Starting_Directory :: %s -*-
Compilation started at %s
]]

local Process = {}
Process.__index = Process

function Process.new()
    local obj = setmetatable({}, Process)
    obj.buf = require("cathy.compile2.buffer").new()

    obj.buf:register_keymap("n", "q", function ()
        vim.cmd [[close]]
    end)

    obj.buf:register_keymap("n", "R", function ()
        obj.buf:replace_lines(0, - 1, {})
        obj.buf._ends_with_newline = false
        require("cathy.compile2.highlights").clear_ns(obj.buf.bufid)
        obj:start(vim.b[obj.buf.bufid].executor, vim.b[obj.buf.bufid].exec_opts)
    end)

    return obj
end

function Process:start(executor, opts)
    vim.validate("executor",      executor,      "string")
    vim.validate("opts",          opts,          "table")
    vim.validate("opts.cmd",      opts.cmd,      "string")
    vim.validate("opts.cwd",      opts.cwd,      "string",   true)
    vim.validate("opts.write_cb", opts.write_cb, "function", true)
    vim.validate("opts.exit_cb",  opts.exit_cb,  "function", true)

    local banner = string.format(
        banner_proto,
        vim.uv.cwd():gsub(os.getenv "HOME", "~"),
        os.date "%a %b %d %H:%M:%S"
    )
    self.buf:append_data(banner)
    self.buf:append_lines({ opts.cmd })

    local highlights = require("cathy.compile2.highlights")
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
            local duration = (vim.uv.hrtime() - self.start_time) / 1e9
            local line, hl = require("cathy.compile2.signalis")[obj.code](duration)
            self.buf:append_lines({ "", line })
            local linenr = self.buf:pos("$")[2]
            hl(self.buf.bufid, highlights.ns, linenr, highlights.get_group(obj.code))
        end)
    }, opts)

    vim.b[self.buf.bufid].executor = executor
    vim.b[self.buf.bufid].exec_opts = opts
    self._proc = require("cathy.compile2.executor")[executor](opts)
end

function Process:kill()
    self._proc:kill("sigint")
end

function Process:create_win()
    local win = vim.api.nvim_open_win(self.buf.bufid, false, {
        split = "below",
        win = 0
    })

    vim.wo[win].spell = false
end

return Process
