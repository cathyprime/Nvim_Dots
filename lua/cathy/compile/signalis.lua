local term_string = "Compilation %s at %s, duration %.2f s"
local term_string_abnormal = "Compilation exited abnormally with code %d at %s, duration %.2f s"
local display = lazy_require("cathy.compile.display")

local H = {
    offsets = {
        term_string = 12,
        term_string_abnormal = 40
    }
}

-- format_string, msg, offset
local msg_func = function (opt)
    return function (duration)
        return string.format(opt.format_string, opt.msg, os.date "%a %b %d %H:%M:%S", duration),
        opt.color_func
    end
end

local function what(msg)
    if type(msg) == "string" then
        return msg_func {
            format_string = term_string,
            msg = msg,
            color_func = display.color_err(#msg, H.offsets.term_string)
        }
    end
    assert(type(msg) == "table")
    local opt = msg
    if opt.abnormal then
        local code_str = tostring(opt[1])
        local col_code = display.color_err(#code_str, H.offsets.term_string_abnormal)
        local col_msg = display.color_err(#"exited abnormally", H.offsets.term_string)
        return msg_func {
            format_string = term_string_abnormal,
            msg = opt[1],
            color_func = function (bufnr, linenr)
                col_code(bufnr, linenr)
                col_msg(bufnr, linenr)
            end
        }
    end
    return msg_func {
        format_string = term_string,
        msg = opt[1],
        color_func = opt[2](#opt[1], H.offsets.term_string)
    }
end

local indexer = function (table, key)
    local code_func = rawget(table, key)
    if code_func then
        return code_func
    end
    return what{ key, abnormal = true }
end

return setmetatable({
    [0]                                = what { "finished", display.color_ok },
    [128 + vim.uv.constants.SIGABRT]   = what "aborted (core dumped)",
    [128 + vim.uv.constants.SIGINT]    = what "interrupted",
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
