local full_module = function (name)
    return "cathy.config." .. vim.fn.fnamemodify(name, ":r")
end

local no_dirs = function (file, type)
    return type == "file"
end

local dir = vim.fs.dir(os.getenv "HOME" .. "/.config/nvim/lua/cathy/config")

local configs = vim.iter(dir)
    :filter(no_dirs)
    :map(full_module)
    :each(require)
