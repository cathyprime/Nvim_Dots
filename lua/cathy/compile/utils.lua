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
        { id = getqf(0).id },
        { __index = QuickFix }
    )
end

local function clear_namespaces(bufnr)
    local each = function (key, value)
        vim.api.nvim_buf_clear_namespace(bufnr, value, 0, -1)
    end
    vim.iter(vim.api.nvim_get_namespaces()):each(each)
end

local function setup_buf_opts(bufnr)
    vim.api.nvim_buf_call(bufnr, function ()
        vim.b.minitrailspace_disable = true
        vim.b.compile_mode = true
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
    local bufnr = getqf(self.id).qfbufnr
    clear_namespaces(getqf(self.id).qfbufnr)

    local winid = getqf(self.id).winid
    local height = math.floor(vim.opt.lines:get() * 0.4 )
    vim.cmd("copen " .. height)

    setup_buf_opts(bufnr)
    setup_win_opts(winid)

    local items = getqf(self.id).items
    vim.fn.setqflist(items, "r", {
        id = self.id,
        quickfixtextfunc = "v:lua.require'cathy.compile.display'.quickfixtextfunc"
    })
end

function QuickFix:set_compiler(compiler)
    if not compiler then
        return
    end
    local bufnr = getqf(self.id).qfbufnr
    vim.api.nvim_buf_call(bufnr, function ()
        local ok, err = pcall(vim.cmd.compiler, compiler)
        if not ok then
            pcall(vim.cmd.compiler, "make")
        end
    end)
end

function QuickFix:apply_color(color_func)
    local qf = getqf(self.id)
    local size = qf.size
    local bufnr = qf.qfbufnr

    color_func(bufnr, size)
end

function QuickFix:set_title(title)
    local items = getqf(self.id).items
    vim.fn.setqflist(items, "r", {
        id = self.id,
        title = title
    })
end

function QuickFix:append_lines(lines)
    if lines.plain then
        lines.plain = nil
        local qf_items = {}
        for _, line in ipairs(lines) do
            table.insert(qf_items, { text = line })
        end
        vim.fn.setqflist({}, 'a', { items = qf_items })
        return
    end
    vim.fn.setqflist({}, "a", { lines = lines, id = self.id })
end

---@class Compile_Opts
---@field compiler string
---@field args string[]
---@field process boolean Defaults to false
---@field cwd string Defaults to vim.uv.cwd()
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
        cwd = vim.uv.cwd()
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
        obj.cwd = vim.fs.normalize(vim.uv.cwd() .. "/" .. obj.cwd)
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
        executable = { self.compiler, unpack(self.args) }
    else
        local script = { "{", self.compiler, unpack(self.args)}
        vim.list_extend(script, { "}", "2>&1" })
        executable = {
            vim.opt.shell:get(),
            vim.opt.shellcmdflag:get(),
            table.concat(script, " ")
        }
        -- executable = {
        --     "script", "-qc",
        --     table.concat(script, " "),
        --     "/dev/null"
        -- }
        -- use this to have ansi escape codes
    end
    return executable
end

return {
    Compile_Opts = Compile_Opts,
    QuickFix = QuickFix,
}
