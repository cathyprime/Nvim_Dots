local term_string = "Compilation %s at %s, duration %.2f s"
local term_string_abnormal = "Compilation exited abnormally with code %d at %s, duration %.2f s"
local ns = vim.api.nvim_create_namespace("Magda_Compile_Mode")

local M = {}
local H = {
    hl_group = {
        ok =  "CompileModeOk",
        err = "CompileModeErr"
    },
    offsets = {
        term_string = 12,
        term_string_abnormal = 40
    }
}

local function hl_exists(name)
    return vim.api.nvim_get_hl(0, { name = name, create = false }) ~= vim.empty_dict()
end

if not hl_exists(H.hl_group.ok) then
    vim.api.nvim_set_hl(0, H.hl_group.ok, { link = "DiffAdd" })
end

if not hl_exists(H.hl_group.err) then
    vim.api.nvim_set_hl(0, H.hl_group.err, { link = "DiffDelete" })
end

local color = function (len, group, start)
    return function (bufnr, linenr)
        vim.hl.range(bufnr, ns, group, { linenr, start }, { linenr, start + len }, { inclusive = false })
    end
end

local function what(msg)
    if type(msg) == "string" then
        return function (duration, linenr)
            return string.format(term_string, msg, os.date "%a %b %d %H:%M:%S", duration),
            color(#msg, H.hl_group.err, H.offsets.term_string)
        end
    end
    local opt = msg
    if opt.abnormal then
        local code_str = tostring(opt[1])
        return function (duration, linenr)
            local col_code = color(#code_str, H.hl_group.err, H.offsets.term_string_abnormal)
            local col_msg = color(#"exited abnormally", H.hl_group.err, H.offsets.term_string)
            return string.format(term_string_abnormal, opt[1], os.date "%a %b %d %H:%M:%S", duration),
            function (bufnr, linenr)
                col_code(bufnr, linenr)
                col_msg(bufnr, linenr)
            end
        end
    end
    return function (duration, linenr)
        return string.format(term_string, opt[1], os.date "%a %b %d %H:%M:%S", duration),
        color(#opt[1], opt[2], H.offsets.term_string)
    end
end

local indexer = function (table, key)
    local code_func = rawget(table, key)
    if code_func then
        return code_func
    end
    return what{ key, H.hl_group.err, abnormal = true }
end

function M.clear_ns(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

M.signals = setmetatable({
    [0]                                = what { "finished", H.hl_group.ok },
    [128 + vim.uv.constants.SIGABRT]   = what "aborted (core dumped)",
    [128 + vim.uv.constants.SIGALRM]   = what "alarm clock",
    [128 + vim.uv.constants.SIGBUS]    = what "bus error (core dumped)",
    [128 + vim.uv.constants.SIGFPE]    = what "floating point exception (core dumped)",
    [128 + vim.uv.constants.SIGHUP]    = what "hangup",
    [128 + vim.uv.constants.SIGILL]    = what "illegal instruction (core dumped)",
    [128 + vim.uv.constants.SIGIO]     = what "i/o possible",
    [128 + vim.uv.constants.SIGKILL]   = what "killed",
    [128 + vim.uv.constants.SIGPROF]   = what "profiling timer expired",
    [128 + vim.uv.constants.SIGPWR]    = what "power failure",
    [128 + vim.uv.constants.SIGSEGV]   = what "segmentation fault (core dumped)",
    [128 + vim.uv.constants.SIGSTKFLT] = what "stack fault",
    [128 + vim.uv.constants.SIGSYS]    = what "bad system call (core dumped)",
    [128 + vim.uv.constants.SIGTERM]   = what "terminated",
    [128 + vim.uv.constants.SIGTRAP]   = what "trace/breakpoint trap (core dumped)",
    [128 + vim.uv.constants.SIGVTALRM] = what "virtual timer expired",
    [128 + vim.uv.constants.SIGXCPU]   = what "cpu time limit exceeded (core dumped)",
    [128 + vim.uv.constants.SIGXFSZ]   = what "file size limit exceeded (core dumped)",
}, { __index = indexer})

return M
