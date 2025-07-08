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

local function getqf(opts)
    if type(opts) == "number" then
        return vim.fn.getqflist({ id = opts, all = 1 })
    end
    return vim.fn.getqflist(opts)
end

---@return QuickFix
function QuickFix.new()
    vim.fn.setqflist({}, " ")
    return setmetatable(
        { id = vim.fn.getqflist({ id = 0 }).id },
        { __index = QuickFix }
    )
end

function QuickFix:open()
    local height = math.floor(vim.opt.lines:get() * 0.4 )
    vim.cmd("copen " .. height)
end

function QuickFix:set_compiler(compiler)
    local bufnr = getqf(self.id).qfbufnr
    if not bufnr then
        return
    end
    vim.api.nvim_buf_call(bufnr, function ()
        local ok = pcall(vim.cmd.compiler, compiler)
        assert(ok, "Compiler not found")
    end)
end

function QuickFix:set_title(title)
    local items = getqf(self.id).items
    vim.fn.setqflist(items, "r", {
        id = self.id,
        title = title
    })
end

function QuickFix:append_lines(lines)
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
        vim_compiler = compiler_exists(cmd.compiler) and cmd.compiler,
        interactive = false
    }

    return setmetatable(vim.tbl_deep_extend("keep", cmd, defaults), { __index = Compile_Opts })
end

---@return string[]
function Compile_Opts:get_plain_cmd()
    local cmd = ""
    if self.compiler ~= "" then
        cmd = self.compiler .. " "
    end
    cmd = cmd .. table.concat(self.args, " ")
    return cmd
end

return {
    Compile_Opts = Compile_Opts,
    QuickFix = QuickFix,
}
