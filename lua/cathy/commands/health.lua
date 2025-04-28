return {
    check = function ()
        vim.health.start("command")
        local executables = {
            "spt", "lazydocker", "lazygit"
        }
        for _, exec in ipairs(executables) do
            if vim.fn.executable(exec) ~= 1 then
                vim.health.warn(exec .. " not found")
            else
                vim.health.ok(exec .. " installed")
            end
        end
    end
}
