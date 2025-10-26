local banner_proto = [[-*- Compilation_Mode; Starting_Directory :: %s -*-
Compilation started at %s
]]

local Process = {}
Process.__index = Process

function Process.new()
    local obj = setmetatable({}, Process)
    obj.buf = require("cathy.compile2.buffer").new()

    buf:register_keymap("n", "q", function ()
        vim.cmd [[close]]
    end)

    buf:register_keymap("n", "R", function ()
        -- recompile
    end)

    return obj
end

function Process:start(executor, opts)
    local banner = string.format(
        banner_proto,
        vim.uv.cwd():gsub(os.getenv "HOME", "~"),
        os.date "%a %b %d %H:%M:%S"
    )
    self.buf:append_data(banner)
    self.buf:append_lines({ opts.cmd })

    local start_time = vim.uv.hrtime()
    opts = vim.tbl_deep_extend("force", {
        cwd = vim.uv.cwd(),
        write_cb = function (err, data)
            assert(not err, err)
            if data then
                self.buf:append_data(data)
            end
        end,
        exit_cb = function (obj)
            local duration = (vim.uv.hrtime() - start_time) / 1e9
            self.buf:append_lines({
                "",
                ""
            })
        end
    }, opts)

    local exec = require("cathy.compile2.executor")[executor]
    self._proc = exec(opts)
end

function Process:kill()
    self._proc:kill("sigint")
end

function Process:create_win()
    self.winid = vim.api.nvim_open_win(buf_id, false, {
        split = "below",
        win = 0
    })
end

return Process
