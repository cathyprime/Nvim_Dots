local dir = vim.fs.dir(os.getenv "HOME" .. "/.config/nvim/lua/cathy/config")
local require = require

local fnamemodify = vim.fn.fnamemodify

-- replace require with measure to get load times
-- local measure = function (mod)
--     local start = vim.uv.hrtime()
--     require(mod)
--     local finish = vim.uv.hrtime()
--     local elapsed = (finish - start) / 1e6
--     vim.notify(string.format("%s :: %.2fms", mod, elapsed))
-- end

for file, typeof_file in dir do
    if typeof_file == "file" then
        local full_module = string
            .format("cathy.config.%s", fnamemodify(file, ":r"))

        require(full_module)
    end
end
