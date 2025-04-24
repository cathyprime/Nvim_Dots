return {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = {
        ".luarc.json",
        ".luarc.jsonc",
        ".luacheckrc",
        ".stylua.toml",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
        ".git",
    },
    on_init = function(client)
        local path
        if client.workspace_folders and client.workspace_folders[1] then
            path = client.workspace_folders[1].name
        else
            path = vim.uv.cwd()
        end
        if vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc') then
            return
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
                version = 'LuaJIT'
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    "${3rd}/luv/library",
                    "$HOME/.config/nvim/lua/",
                },
            }
        })
        client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end,
    settings = {
        Lua = {}
    }
}
