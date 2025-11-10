local banner_proto = [[-*- Compilation_Mode; Starting_Directory :: %s -*-
Compilation started at %s]]

local Process = {}
Process.__index = Process

function Process:create_buf(name)

    self.buf = require("cathy.compile.buffer").new(name)
    self.e = require("cathy.compile.errors").new()
    self.e:attach(self.buf.bufid)

    self.buf:register_keymap("n", "q", function ()
        vim.cmd [[close]]
    end)

    self.buf:register_keymap("n", "<c-c>", function ()
        if self.is_running then
            self:kill()
        end
    end)

    self.buf:register_keymap("n", "<cr>", function()
        local item = self.e[vim.fn.line(".")]
        if not item then return end

        local target_win = nil
        for _, winid in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(winid) == item.bufnr then
                target_win = winid
                break
            end
        end
        target_win = target_win or vim.fn.win_getid(vim.fn.winnr('#'))

        local col = item.col ~= 0 and item.col - 1 or 0
        vim.api.nvim_win_set_buf(target_win, item.bufnr)
        vim.api.nvim_win_set_cursor(target_win, { item.lnum, item.col })
        vim.api.nvim_set_current_win(target_win)
    end)

    self.buf:register_keymap("n", "R", function ()
        if self.is_running then
            return
        end
        self.e:clear()
        self.buf:replace_lines(0, - 1, {})
        self.buf._ends_with_newline = false
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
    self.buf:append_lines({ "", "[CMD] :: " .. opts.cmd })
    local line = self.buf:pos("$")[2]

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
            local line = require("cathy.compile.signalis")[exit_code]((vim.uv.hrtime() - self.start_time) / 1e9)
            if self.buf:lines(-2, -1)[1] == "" then
                self.buf:append_lines { line }
            else
                self.buf:append_lines { "", line }
            end
            local linenr = self.buf:pos("$")[2]
            vim.api.nvim_exec_autocmds("User", {
                pattern = "CompileFinished",
            })
        end)
    }, opts)

    vim.b[self.buf.bufid].executor = executor
    vim.b[self.buf.bufid].exec_opts = opts
    self.is_running = true
    self:show()
    self._proc = require("cathy.compile.executor")[executor](opts)
end

function Process:kill()
    if self.is_running then
        self._proc:kill()
    end
end

function Process:show()
    if not self.buf then
        return
    end
    -- might be some saved buffer in old buffer list
    self.buf:apply_settings()

    local with_any_compile_buf = vim.tbl_filter(function (win)
        local buffer = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buffer)
        return name:find("Compile://")
    end, vim.api.nvim_list_wins())

    local win = with_any_compile_buf[1]

    if not win then
        win = vim.api.nvim_open_win(self.buf.bufid, false, {
            split = "below",
            win = 0
        })
    end
    vim.api.nvim_set_current_win(win)

    vim.wo[win].list  = false
    vim.wo[win].spell = false
end

return Process
