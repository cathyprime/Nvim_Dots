local M = {}
local H = {}

local function git(cmd)
    local callback = cmd.callback
    cmd.callback = nil
    vim.system(cmd, { text = true, detach = true }, function (result)
        if result.code == 128 then
            callback()
            return
        end

        if result.code ~= 0 or result.signal ~= 0 then
            return
        end

        local data = vim.split(result.stdout, "\n", { plain = true, trimempty = true })
        if #data ~= 1 then
            callback()
        end
        callback(data[1])
    end)
end

---@param path string
---@param callback fun(res: string|nil)
function H.git_current(path, callback)
    git {
        "git",
        "-C", path,
        "rev-parse",
        "--show-toplevel",
        callback = callback
    }
end

---@param path string
---@param callback fun(result: string|nil)
function H.git_superproject(path, callback)
    git {
        "git",
        "-C", path,
        "rev-parse",
        "--show-superproject-working-tree",
        callback = callback
    }
end

---@param superpath string
---@param current_path string
function H.superproject_to_scope(superpath, current_path)
    superpath    = vim.fs.normalize(superpath)
    current_path = vim.fs.normalize(current_path)
    local Projects = require("cathy.projectile.projects")
    local new_scope = vim.fs.relpath(superpath, current_path)
    local proj_name = Projects:register(superpath)
    table.insert(Projects[proj_name].scopes, new_scope)
    Projects[proj_name].selected_scope = #Projects[proj_name].scopes
    return proj_name
end

local markers = {
    "CMakeLists.txt",
    ".git",
}

function H.check_for_markers(bufpath, callback)
    bufpath = vim.fs.normalize(bufpath)
    local Projects = require "cathy.projectile.projects"

    local function join_paths(...)
        return vim.fs.normalize(vim.fs.joinpath(...))
    end

    local function search(path)
        local parent = vim.fs.dirname(path)

        if parent == path then
            callback(nil)
            return
        end

        for _, marker in ipairs(markers) do
            local full = vim.fs.joinpath(path, marker)
            if vim.fn.filereadable(full) == 1 then
                local name = Projects:register(path)
                callback(name)
                return
            end
        end
        search(parent)
    end
    search(bufpath)
end

---@param bufpath string
---@param callback fun(project_name: string|nil)
function H.process_path(bufpath, callback)
    if vim.fn.isdirectory(bufpath) == 0 then
        bufpath = vim.fs.dirname(bufpath, ":p:h")
    end

    local Projects = require("cathy.projectile.projects")
    local name = Projects:path_contained(bufpath)
    if name then
        callback(name)
        return
    end

    H.git_current(bufpath, function (repo_path)
        if not repo_path then
            H.check_for_markers(bufpath, callback)
            return
        end

        H.git_superproject(repo_path, function (super_repo)
            if not super_repo then
                local Projects = require("cathy.projectile.projects")
                local name = Projects:register(repo_path)
                callback(name)
                return
            end

            local name = H.superproject_to_scope(super_repo, repo_path)
            callback(name)
        end)
    end)
end

---@param project_name string
function H.display_buffer(project_name)
    local Projects = require "cathy.projectile.projects"
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, Projects[project_name].scopes)
    vim.bo[buf].ft = "text"
    vim.api.nvim_create_autocmd({ "BufDelete", "BufHidden" }, {
        buffer = bufnr,
        once = true,
        callback = function ()
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
            if #lines == 1 and lines[1] == "" then
                lines = {}
            end
            Projects[project_name].scopes = lines
        end
    })
    local close_buf = function ()
        local ok, _ = pcall(vim.cmd.close)
        if not ok then
            vim.cmd.bdelete()
        end
    end
    local opts = {
        buffer = buf,
        silent = true,
        noremap = true,
        nowait = true
    }
    vim.keymap.set("n", "<esc>", function ()
        Projects[project_name].selected_scope = 0
        close_buf()
    end, opts)
    vim.keymap.set("n", "<cr>", function ()
        Projects[project_name].selected_scope = vim.fn.line(".")
        close_buf()
    end, opts)
    vim.keymap.set("n", "q", close_buf, opts)
    local size = 0.40

    local columns = vim.opt.columns:get()
    local lines = vim.opt.lines:get()
    local i_size = (1 - size) / 2

    local height = math.floor(lines   * size)
    local width  = math.floor(columns * size)
    local row    = math.floor(lines   * i_size)
    local col    = math.floor(columns * i_size)

    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "single",
        title = "Scopes://" .. Projects[project_name]:get_path(),
        title_pos = "center"
    })
end

---@param bufpath string
function M.switch_cwd(bufpath, is_oil)
    if not bufpath or bufpath == "" then
        return
    end
    local Projects = require "cathy.projectile.projects"
    bufpath = vim.fs.normalize(bufpath)
    H.process_path(bufpath, vim.schedule_wrap(function (project_name)
        if not project_name  then
            if is_oil then
                vim.cmd.cd {
                    args = { bufpath },
                    mods = { silent = true }
                }
            end
            return
        end
        vim.cmd.cd {
            args = {
                Projects[project_name]:get_path()
            },
            mods = { silent = true }
        }
    end))
end

---@param path string
---@param name string
function M.add_project(path, name)
    path = vim.fs.normalize(path)
    local Projects = require "cathy.projectile.projects"
    Projects:register(path, name)
end

function M.edit_scopes()
    local Projects = require "cathy.projectile.projects"
    local name = Projects:path_contained(vim.uv.cwd())
    if name then
        H.display_buffer(name)
        return
    end
    H.process_path(vim.uv.cwd(), function (project_name)
        if not project_name then
            local ok, result = pcall(vim.fn.confirm, "No project found for current path, create?", "&Yes\n&No", 2)
            if not ok or result ~= 1 then
                return
            end
            project_name = Projects:register(vim.uv.cwd())
        end
        H.display_buffer(project_name)
    end)
end

---@return table<string>
function M.list_projects()
    local Projects = require "cathy.projectile.projects"
    return vim.iter(Projects):map(function (name, p)
        return { text = name, path = p.path }
    end):totable()
end

return M
