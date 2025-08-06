local flags = {
    CWD = "--cwd::",
    COMPILER = "--compiler::",
    PROCESS = "--process"
}

local function val(arg, flag)
    return (arg:sub(#flag + 1))
end

local params = {
    [flags.CWD] = function (arg)
        return "cwd", val(arg, flags.CWD)
    end,
    [flags.COMPILER] = function (arg)
        return "vim_compiler", val(arg, flags.COMPILER)
    end,
    [flags.PROCESS] = function (arg)
        return "process", true
    end
}

local H = {}

function H.is_compiler_opt(arg)
    for k, v in pairs(params) do
        if arg:find(k, 1, true) then
            local key, value = v(arg)
            return true, { key = key, argument = value }
        end
    end
    return false
end

function H.is_interactive(str)
    local args = vim.trim(str)
    return args:sub(-1) == "&"
end

function H.strip_interactive(fargs)
    if fargs[#fargs] == "&" then
        fargs = table.remove(fargs)
        return ev
    end

    local last = fargs[#fargs]
    assert(last:sub(-1) == "&", "UNREACHABLE")

    fargs[#fargs] = last:sub(1, -2)
    return fargs
end

function H.escape_args(args)
    for i, value in ipairs(args) do
        args[i] = vim.fn.shellescape(value)
    end
    return args
end

function H.parse_compile_args(ev)
    ---@type Compile_Opts
    local cmd = {}
    local arg = table.remove(ev.fargs, 1)

    while true do
        local ok, ret = H.is_compiler_opt(arg)
        if not ok then break end
        assert(ret ~= nil)
        arg = table.remove(ev.fargs, 1)
        cmd[ret.key] = ret.argument
    end

    cmd.compiler = arg
    if H.is_interactive(ev.args) then
        cmd.interactive = true
        cmd.args = H.strip_interactive(ev.fargs)
    elseif ev.bang then
        cmd.interactive = true
        cmd.args = ev.fargs
    else
        cmd.args = ev.fargs
    end

    return require("cathy.compile.utils").Compile_Opts.new(cmd)
end

local last_compile = nil

local compile = function (e)
    if type(e) ~= "boolean" then
        last_compile = H.parse_compile_args(e)
    end

    if not last_compile then
        vim.notify("No previous compile command!", vim.log.levels.WARN)
        return
    end

    require("cathy.compile").exec(last_compile)
end

vim.keymap.set("n", "'<cr>", "<cmd>Recompile<cr>", { silent = false })
vim.keymap.set("n", "'<space>", ":Compile", { silent = false })
vim.api.nvim_create_user_command(
    "Compile",
    function (e)
        if #e.fargs == 0 then
            vim.ui.input({
                prompt = "Compile :: ",
                default = last_compile and last_compile:get_plain_cmd()
            }, function (input)
                if not input then
                    vim.notify("No command", vim.log.levels.WARN)
                    return
                end

                e.args = input
                e.fargs = vim.split(input, " ", { plain = true, trimempty = false })
                compile(e)
            end)
            return
        end

        compile(e)
    end,
    {
        nargs = "*",
        bang = true
    }
)

vim.api.nvim_create_user_command(
    "Recompile",
    function (e)
        if e.bang then
            last_compile.interactive = not last_compile.interactive
        end
        compile(true)
    end,
    {
        nargs = 0,
        bang = true
    }
)
