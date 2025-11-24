local bg_path = vim.fs.joinpath(vim.fn.stdpath("data"), "bg.txt")


local function load()
    vim.uv.fs_open(bg_path, "r", tonumber("666", 8), function(err_open, fd)
        if err_open or not fd then return end

        vim.uv.fs_fstat(fd, function(err_stat, stat)
            if err_stat or not stat then
                vim.uv.fs_close(fd)
                return
            end

            vim.uv.fs_read(fd, stat.size, 0, function(err_read, data)
                vim.uv.fs_close(fd)
                if err_read or not data then return end

                local value = vim.trim(data)
                vim.schedule(function()
                    vim.opt.background = value
                end)
            end)
        end)
    end)
end

local function save()
    local value = vim.opt.background:get()
    local file = io.open(bg_path, "w")
    file:write(value)
    file:flush()
    file:close()
end

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = load
})

vim.api.nvim_create_autocmd("VimLeavePre", {
    once = true,
    callback = save
})
