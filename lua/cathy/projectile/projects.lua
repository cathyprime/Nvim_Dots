---@class Project
---@field path string
---@field scopes table<string>
---@field selected_scope number
local Project = {}

---@param path string
local function basename(path)
    return vim.fn.fnamemodify(path, ":t")
end

---@param ... string
local function join_paths(...)
    return vim.fs.normalize(vim.fs.joinpath(...))
end

function Project:get_path()
    if self.selected_scope == 0 then
        return self.path
    end
    if self.selected_scope > #self.scopes then
        self.selected_scope = #self.scopes
    end
    return join_paths(self.path, self.scopes[self.selected_scope])
end

---@param path string
---@return Project
function Project.new(path)
    local obj = setmetatable({}, { __index = Project })
    obj.path = path
    obj.scopes = {}
    obj.selected_scope = 0
    return obj
end

local function save_table(self)
    local path = join_paths(vim.fn.stdpath("data"), "projects.json")
    local json = vim.json.encode(self)
    vim.fn.mkdir(vim.fn.stdpath("data"), "p")
    vim.fn.writefile({ json }, path)
end

local function load_table(self)
    local path = join_paths(vim.fn.stdpath("data"), "projects.json")

    if not vim.uv.fs_stat(path) then
        return
    end

    local data = table.concat(vim.fn.readfile(path), "\n")
    for k, _ in pairs(self) do
        self[k] = nil
    end

    local ok, decoded = pcall(vim.json.decode, data)
    if not ok or type(decoded) ~= "table" then
        error "failed to decode"
        return
    end

    for name, info in pairs(decoded) do
        self[name] = setmetatable({
            path = info.path,
            scopes = info.scopes,
            selected_scope = info.selected_scope
        }, { __index = Project })
    end
end

local ProjectsMethods = {
    __index = function (self, key)
        load_table(self)
        return rawget(self, key)
    end,
    register = function (self, path, name)
        path = vim.fs.normalize(path)
        name = name or basename(path)
        self[name] = Project.new(path)
        return name
    end,
    save = save_table,
    load = load_table,
    is_project = function (self, path)
        path = vim.fs.normalize(path)
        for name, project in pairs(self) do
            if project.path == path then
                return name
            end
        end
    end,
    path_contained = function (self, bufpath)
        bufpath = vim.fs.normalize(bufpath)
        local path_len = 0
        local selected_project = nil

        for name, project in pairs(self) do
            if bufpath:sub(1, #project.path) == project.path then
                if path_len < #project.path then
                    selected_project = name
                    path_len = #project.path
                end
            end
        end
        return selected_project
    end
}

---@class Projects
---@field register fun(self: Projects, path: string): string
---@field path_contained fun(self: Projects, bufpath: string): string|nil
---@field is_project fun(self: Projects, path: string): string
---@field save fun()
---@field load fun()
---@field [string] Project will call load() on first index
local Projects = setmetatable({}, {
    __index = function(self, key)
        if not rawget(ProjectsMethods, "__was_loaded") then
            load_table(self)
            vim.api.nvim_create_autocmd("VimLeavePre", {
                callback = function ()
                    require("cathy.projectile.projects"):save()
                end
            })
            rawset(ProjectsMethods, "__was_loaded", true)
        end

        local method = ProjectsMethods[key]
        if method then return method end

        return rawget(self, key)
    end
})

return Projects
