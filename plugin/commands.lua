vim.api.nvim_create_user_command(
    "Trim",
    function()
        local ok, ts = pcall(require, "mini.trailspace")
        if ok then
            ts.trim()
        end
    end,
    {
        desc = "Trim whitespace from current buffer"
    }
)

vim.api.nvim_create_user_command(
    "Read",
    function(opts)
        local out = vim.split(vim.api.nvim_exec2(opts.args, { output = true }).output, "\n", {})
        local row = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_buf_set_lines(0, row[1], row[1], false, out)
    end,
    {
        nargs = "*"
    }
)

vim.api.nvim_create_user_command(
    "DarkMode",
    function()
        if vim.o.background == "light" then
            vim.o.background = "dark"
        else
            vim.o.background = "light"
        end
    end,
    {
        desc = "toggle dark mode"
    }
)

local function create_command(cmd, argument, desc)
    vim.api.nvim_create_user_command(
        cmd,
        function()
            if vim.fn.executable("spt") ~= 1 then
                vim.notify("spt not found!", vim.log.levels.ERROR)
                return
            end
            vim.system({
                "spt",
                "playback",
                argument,
            })
        end,
        {
            desc = desc,
        }
    )
end

local function executable_term(cmd, program, opts)
    vim.api.nvim_create_user_command(
        cmd,
        function(env)
            if vim.fn.executable(program) ~= 1 then
                vim.notify(program .. " not found!", vim.log.levels.ERROR)
                return
            end
            table.insert(env.fargs, 1, program)
            local tab_term = require("cathy.utils")[opts.func_cmd](env.fargs, opts.func_opts)
        end,
        {
            desc = opts.desc or nil,
            nargs = opts.nargs or nil,
        }
    )
end
executable_term("Docker", "lazydocker", {
    desc = "Open lazydocker",
    func_cmd = "tab_term",
    func_opts = { title = "Docker", close = true }
})
executable_term("LazyGit", "lazygit", {
    desc = "Open lazygit",
    func_cmd = "tab_term",
    func_opts = { title = "Lazygit", close = true }
})
executable_term("Spotify", "spt", {
    desc = "Open spotify",
    func_cmd = "tab_term",
    func_opts = { title = "Spotify", close = true }
})

create_command("SpotifyRepeat",  "--repeat",   "toggle repeat mode")
create_command("SpotifyPP",      "--toggle",   "play/pause the music")
create_command("SpotifyLike",    "--like",     "like the current song")
create_command("SpotifyDisLike", "--dislike",  "dislike the current song")
create_command("SpotifyNext",    "--next",     "switch to the next track")
create_command("SpotifyPrev",    "--previous", "switch to the previous track")

vim.api.nvim_create_user_command(
    "Delview",
    function()
        local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
        if path == nil then
            vim.notify("error getting path", vim.log.levels.ERROR)
            return
        end
        path = vim.fn.substitute(path, "=", "==", "g")
        if path == nil then
            vim.notify("error doubling equal signs", vim.log.levels.ERROR)
            return
        end
        path = vim.fn.substitute(path, "^" .. os.getenv("HOME"), "\\~", "")
        if path == nil then
            vim.notify("substitute error", vim.log.levels.ERROR)
            return
        end
        path = vim.fn.substitute(path, "/", "=+", "g") .. "="
        local file_path = vim.opt.viewdir:get() .. path
        local int = vim.fn.delete(file_path)
        if int == -1 then
            vim.notify("View not found!", vim.log.levels.ERROR)
        else
            vim.notify(string.format("deleted view: %s", file_path), vim.log.levels.INFO)
        end
    end,
    {
        desc = "Delete saved view"
    }
)
