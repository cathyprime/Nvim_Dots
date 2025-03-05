local on = false
local root_names = {
    "%.csproj$",
    "docker%-compose%.yml",
    "build%.sbt",
    "Cargo%.toml",
    "go%.mod",
    "main.cpp",
    "main.cc",
    "main.c",
    "gradlew",
    "/lua",
    "Makefile",
    "package%.json",
    "%.git",
}

local disabled_filetype = {
    "help",
    "qf",
    "Neogit.*",
}

local function isBanned(ft)
    if ft == "" then return true end
    return vim.iter(disabled_filetype):any(function(v)
        return ft:match(v)
    end)
end

local function pattern_detector(always_run)
    if isBanned(vim.o.filetype) then return end
    if not on and not always_run then return end
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then return end

    local root = vim.fs.root(0, function(name)
        return vim.iter(root_names):any(function(value)
            return name:match(value)
        end)
    end)
    return root
end

local function realpath(path)
    if path == "" or path == nil then
        return nil
    end
    path = vim.uv.fs_realpath(path) or path
    return path
end

local function lsp_detector()
    local bufpath = realpath(vim.api.nvim_buf_get_name(0))
    if not bufpath then
        return {}
    end
    local roots = {}
    local buffer = vim.api.nvim_get_current_buf()
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = buffer })) do
        local workspace = client.config.workspace_folders
        for _, ws in pairs(workspace or {}) do
            roots[#roots + 1] = vim.uri_to_fname(ws.uri)
        end
        if client.root_dir then
            roots[#roots + 1] = client.root_dir
        end
    end
    return vim.tbl_filter(function(path)
        return path and bufpath:find(path, 1, true) == 1
    end, roots)
end

local function get_root(always_run)
    local roots = lsp_detector()
    if roots and #roots > 1 then
        return roots[1]
    end
    return pattern_detector(always_run)
end

local function set_root()
    local root = get_root()
    local old = vim.fn.getcwd()
    if old ~= root and root ~= "." and root ~= "/" and root ~= nil then
        vim.notify(string.format("cwd: %s", root), vim.log.levels.INFO)
        vim.fn.chdir(root)
    end
end

local switch = {
    enable = function(notif)
        if not on then
            notif("Rooter: on")
            on = true
        end
    end,
    disable = function(notif)
        if on then
            notif("Rooter: off")
            on = false
        end
    end,
    toggle = function(notif)
        on = not on
        if on then
            notif("Rooter: on")
        else
            notif("Rooter: off")
        end
    end,
    status = function(notif)
        if on then
            notif("Rooter: on")
        else
            notif("Rooter: off")
        end
    end,
    cwd = function(notif)
        notif(string.format("cwd: %s", vim.fn.getcwd()), vim.log.levels.INFO)
    end
}

return {
    get_root = get_root,
    setup = function(opts)
        if on then
            return
        end
        on = true
        vim.api.nvim_create_user_command(
            "Rooter",
            function(opts)
                local notif = function(msg, level)
                    level = level or vim.log.levels.INFO
                    vim.notify(msg, level)
                end
                if opts.smods.silent or (opts and opts.silent) then
                    notif = function() end
                end
                if opts.args == "" then
                    set_root()
                else
                    local f = switch[opts.args]
                    if f == nil then
                        notif("Rooter: unknown command", vim.log.levels.ERROR)
                        return
                    end
                    f(notif)
                end
            end,
            {
                nargs = "*",
                complete = function(arg_lead)
                    return vim.iter({ "enable", "disable", "toggle", "status", "cwd" }):filter(function(el)
                        return el:lower():match("^" .. arg_lead)
                    end):totable()
                end
            }
        )
        vim.api.nvim_create_autocmd("BufEnter", {
            group = vim.api.nvim_create_augroup("rooter", {}),
            callback = set_root,
        })
    end
}
