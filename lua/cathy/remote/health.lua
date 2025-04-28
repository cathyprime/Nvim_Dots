return {
    check = function ()
        vim.health.start("remote")
        if vim.fn.executable("ssh") == 1 then
            vim.health.ok("ssh installed")
        else
            vim.health.error("ssh missing")
        end
        if vim.fn.executable("sshfs") == 1 then
            vim.health.ok("sshfs installed")
        else
            vim.health.error("sshfs missing")
        end
    end
}
