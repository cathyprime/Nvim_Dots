local M = {}
local to_check = { "fd", "fdfind", "rg", "find" }

local remote_available = function (prog)
    local cmd = "which " .. prog
    local ssh = require("cathy.remote.utils").get_ssh_cmd(cmd)
    local code = vim.system({ "bash", "-c", ssh }, { stdout = false, stderr = false }):wait().code
    if code == 124 then
        vim.notify("Issue connecting to remote server", vim.log.levels.ERROR)
        return
    end
    return code == 0
end

local function get_cmd(opts, filter)
    local cmd, args = require("snacks.picker.source.files").get_cmd(opts.cmd)
    if not cmd or not args then
        return
    end
    cmd = opts.cmd
    local is_fd, is_fd_rg, is_find, is_rg = cmd == "fd" or cmd == "fdfind", cmd ~= "find", cmd == "find", cmd == "rg"


    -- exclude
    for _, e in ipairs(opts.exclude or {}) do
        if is_fd then
            vim.list_extend(args, { "-E", e })
        elseif is_rg then
            vim.list_extend(args, { "-g", "!" .. e })
        elseif is_find then
            table.insert(args, "-not")
            table.insert(args, "-path")
            table.insert(args, e)
        end
    end


    -- extensions
    local ft = opts.ft or {}
    ft = type(ft) == "string" and { ft } or ft
    ---@cast ft string[]
    for _, e in ipairs(ft) do
        if is_fd then
            table.insert(args, "-e")
            table.insert(args, e)
        elseif is_rg then
            table.insert(args, "-g")
            table.insert(args, "*." .. e)
        elseif is_find then
            table.insert(args, "-name")
            table.insert(args, "*." .. e)
        end
    end


    -- hidden
    if opts.hidden and is_fd_rg then
        table.insert(args, "--hidden")
    elseif not opts.hidden and is_find then
        vim.list_extend(args, { "-not", "-path", "*/.*" })
    end


    -- ignored
    if opts.ignored and is_fd_rg then
        args[#args + 1] = "--no-ignore"
    end


    -- follow
    if opts.follow then
        args[#args + 1] = "-L"
    end


    -- extra args
    vim.list_extend(args, opts.args or {})


    -- file glob
    ---@type string?
    local pattern, pargs = Snacks.picker.util.parse(filter.search)
    vim.list_extend(args, pargs)


    pattern = pattern ~= "" and pattern or nil
    if pattern then
        if is_fd then
            table.insert(args, pattern)
        elseif is_rg then
            table.insert(args, "--glob")
            table.insert(args, pattern)
        elseif is_find then
            table.insert(args, "-name")
            table.insert(args, pattern)
        end
    end


    -- dirs
    local dirs = opts.dirs or {}
    if opts.rtp then
        vim.list_extend(dirs, Snacks.picker.util.rtp())
    end
    if #dirs > 0 then
        dirs = vim.tbl_map(svim.fs.normalize, dirs) ---@type string[]
        if is_fd and not pattern then
            args[#args + 1] = "."
        end
        if is_find then
            table.remove(args, 1)
            for _, d in pairs(dirs) do
                table.insert(args, 1, d)
            end
        else
            vim.list_extend(args, dirs)
        end
    end

    return require("cathy.remote.utils").get_ssh_cmd(cmd), args
end


---@param opts snacks.picker.files.Config
---@type snacks.picker.finder
function M.files(opts, ctx)
    if not vim.g.remote_connected_hostname then
        return require("snacks.picker.source.files").files(opts, ctx)
    end

    local cwd = not (opts.rtp or (opts.dirs and #opts.dirs > 0))
        and svim.fs.normalize(opts and opts.cwd or vim.uv.cwd() or ".")
        or nil

    for _, c in ipairs(to_check) do
        if remote_available(c) then
            opts.cmd = c
            break
        end
    end

    if not opts.cmd then
        vim.notify("No supported finder found", vim.log.levels.ERROR)
        return
    end

    local cmd, args = get_cmd(opts, ctx.filter)
    if not cmd then
        return function() end
    end
    if opts.debug.files then
        Snacks.notify(cmd .. " " .. table.concat(args or {}, " "))
    end
    table.insert(args, 1, cmd)
    return require("snacks.picker.source.proc").proc({
        opts,
        {
            cmd = "bash",
            args = {
                "-c",
                table.concat(args, " ")
            },
            notify = not opts.live,
            ---@param item snacks.picker.finder.Item
            transform = function(item)
                item.cwd = cwd
                item.file = item.text
            end,
        },
    }, ctx)
end

return M
