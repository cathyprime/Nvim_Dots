local flags = {
    CWD = "--cwd::",
    COMPILER = "--compiler::"
}

local function flag_to_opt(flag)
    return (flag:sub(3)):sub(1, -3)
end

local params = {
    [flags.CWD] = function (arg)
        return flag_to_opt(flags.CWD), (arg:sub(#flags.CWD + 1))
    end,
    [flags.COMPILER] = function (arg)
        return "vim_" .. flag_to_opt(flags.COMPILER), (arg:sub(#flags.COMPILER + 1))
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
    else
        cmd.args = ev.fargs
    end

    return require("cathy.compile.utils").Compile_Opts.new(cmd)
end

local last_compile = nil

vim.keymap.set("n", "'<cr>", "<cmd>Compile<cr>", { silent = false })
vim.keymap.set("n", "'<space>", ":Compile ", { silent = false })
vim.api.nvim_create_user_command(
    "Compile",
    function (e)
        if #e.fargs ~= 0 then
            last_compile = H.parse_compile_args(e)
        end

        if not last_compile then
            return
        end

        require("cathy.compile")
            .exec(last_compile)
    end,
    { nargs = "*" }
)
