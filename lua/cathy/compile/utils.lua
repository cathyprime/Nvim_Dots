---@class QuickFix
---@field id number
local QuickFix = {}

local function compiler_exists(compiler)
    local to_name = function (path)
        return vim.fn.fnamemodify(path, ":t:r")
    end
    local rtp = table.concat(vim.opt.runtimepath:get(), ",")
    local paths = vim.fn.globpath(rtp, "compiler/*.vim", 0, 1)
    local compilers = vim.iter(paths)
        :map(to_name)
        :totable()

    return vim.list_contains(compilers, compiler)
end

local function getqf(id)
    return vim.fn.getqflist({ id = id, all = 1 })
end

---@return QuickFix
function QuickFix.new()
    local bufnr = vim.api.nvim_create_buf(false, false)
    vim.fn.setqflist({}, " ", { bufnr = bufnr })
    return setmetatable(
        { id = vim.fn.getqflist({ id = 0, all = 1 }).id },
        { __index = QuickFix }
    )
end

local function clear_namespaces(bufnr)
    for name, id in pairs(vim.api.nvim_get_namespaces()) do
        if name ~= "Oil" then
            vim.api.nvim_buf_clear_namespace(bufnr, id, 0, -1)
        end
    end
end

local function setup_buf_opts(bufnr)
    vim.keymap.set("n", "<c-c>", function ()
        local job = require("cathy.compile").running_job
        if job then
            local pid = vim.fn.jobpid(job)
            if pid then
                vim.uv.kill(-pid, "sigint")
            end
        end
    end, { buffer = bufnr })
    vim.api.nvim_buf_call(bufnr, function ()
        vim.b.compile_mode = true
        vim.b.minitrailspace_disable = true
        vim.opt_local.modifiable = false
    end)
    vim.api.nvim_create_autocmd("QuickFixCmdPost", {
        pattern = "*",
        once = true,
        callback = function ()
            if vim.api.nvim_buf_is_valid(bufnr) then
                vim.api.nvim_buf_call(bufnr, function ()
                    require("cathy.compile.display").clear_ns(bufnr)
                    vim.b.minitrailspace_disable = nil
                    vim.b.compile_mode = nil
                    vim.opt_local.modifiable = true
                end)
            end
        end
    })
end

local function setup_win_opts(winid)
    vim.api.nvim_win_call(winid, function ()
        vim.wo.list = false
        vim.wo.winfixbuf = true
    end)
    vim.api.nvim_create_autocmd("QuickFixCmdPost", {
        pattern = "*",
        callback = function ()
            if vim.api.nvim_win_is_valid(winid) then
                vim.api.nvim_win_call(winid, function ()
                    require("quicker").refresh(winid)
                    vim.wo.list = true
                    vim.wo.winfixbuf = false
                end)
            end
        end
    })
end

function QuickFix:open()
    local bufnr = self:get().qfbufnr
    clear_namespaces(self:get().qfbufnr)

    local winid = self:get().winid
    local height = math.floor(vim.opt.lines:get() * 0.4 )
    vim.cmd("copen " .. height)

    setup_buf_opts(bufnr)
    setup_win_opts(winid)

    local items = self:get().items
    vim.fn.setqflist(items, "r", {
        id = self.id,
        quickfixtextfunc = "v:lua.require'cathy.compile.display'.quickfixtextfunc"
    })
end

function QuickFix:get()
    return vim.fn.getqflist({ id = self.id, all = 1 })
end

function QuickFix:set_compiler(compiler)
    if not compiler then
        return
    end
    local bufnr = self:get().qfbufnr
    vim.api.nvim_buf_call(bufnr, function ()
        local ok, err = pcall(vim.cmd.compiler, compiler)
        if not ok then
            pcall(vim.cmd.compiler, "make")
        end
    end)
end

function QuickFix:apply_color(color_func, start)
    local qf = self:get()
    start = start or qf.size
    local bufnr = qf.qfbufnr

    color_func(bufnr, start)
end

function QuickFix:set_title(title)
    local items = self:get().items
    vim.fn.setqflist(items, "r", {
        id = self.id,
        title = title
    })
end

function QuickFix:clear()
    vim.fn.setqflist({}, "r")
end

function QuickFix:append_lines(lines)
    if lines.plain then
        lines.plain = nil
        local qf_items = {}
        for _, line in ipairs(lines) do
            table.insert(qf_items, { text = line })
        end
        vim.fn.setqflist({}, 'a', { items = qf_items })
        vim.cmd.cbottom()
        return
    end
    vim.fn.setqflist({}, "a", { lines = lines, id = self.id })
    vim.cmd.cbottom()
end

---@class Compile_Opts
---@field compiler string
---@field args string[]
---@field process boolean Defaults to false
---@field cwd string Defaults to require("cathy.scopes").get_root()
---@field interactive boolean Defaults to false
---@field vim_compiler string? Defaults to self.compiler
local Compile_Opts = {}

---@return Compile_Opts
function Compile_Opts.new(cmd)
    vim.validate("cmd.compiler", cmd.compiler, "string")
    vim.validate("cmd.args", cmd.args, "table", true)
    vim.validate("cmd.process", cmd.process, "boolean", true)
    vim.validate("cmd.cwd", cmd.cwd, "string", true)
    vim.validate("cmd.vim_compiler", cmd.vim_compiler, "string", true)
    vim.validate("cmd.interactive", cmd.interactive, "boolean", true)

    local cwd
    local oil_dir = require("oil").get_current_dir()
    if oil_dir then
        cwd = oil_dir
    end

    if not cwd then
        local expand = vim.fn.expand("%:p:h")
        if expand:match "^term" then
            cwd = vim.fn.fnamemodify(expand:gsub("term://", ""):gsub("//.*", ""), ":p")
        end
    end

    if not cwd then
        cwd = require("cathy.scopes").get_root()
    end

    local defaults = {
        args = {},
        process = false,
        cwd = cwd,
        vim_compiler = cmd.compiler,
        interactive = false
    }

    local obj = setmetatable(vim.tbl_deep_extend("keep", cmd, defaults), { __index = Compile_Opts })
    if string.sub(obj.cwd, 1, 1) ~= "/" then
        obj.cwd = vim.fs.normalize(require("cathy.scopes").get_root() .. "/" .. obj.cwd)
    end
    return obj
end

---@return string[]
function Compile_Opts:get_plain_cmd()
    local cmd = ""
    cmd = cmd .. table.concat(self.args, " ")
    if cmd ~= "" then
        cmd = self.compiler .. " " .. cmd
    else
        cmd = self.compiler
    end
    return cmd
end

function Compile_Opts:make_executable()
    local executable
    if self.process then
        executable = table.concat({ self.compiler, unpack(self.args) }, " ")
    else
        local script = (([[run() {
    if [ $# -eq 0 ]; then
        return 1;
    fi;
    local cmd=$(printf '%q ' "$@");
    eval "$cmd" 2>&1;
}; run ]]):gsub("\n", "")) .. table.concat({ self.compiler, unpack(self.args) }, " ")
        executable = {
            vim.opt.shell:get(),
            vim.opt.shellcmdflag:get(),
            script
        }
    end
    return executable
end

return {
    Compile_Opts = Compile_Opts,
    QuickFix = QuickFix,
}
