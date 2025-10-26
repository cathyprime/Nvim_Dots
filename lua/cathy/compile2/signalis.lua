local term_string = "Compilation %s at %s, duration %.2f s"
local term_string_abnormal = "Compilation exited abnormally with code %d at %s, duration %.2f s"

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
