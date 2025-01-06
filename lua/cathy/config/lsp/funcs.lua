local telescope = require("cathy.utils.telescope")
local lspconfig = require("lspconfig")

local function telescope_references()
    require("telescope.builtin").lsp_references({
        include_declaration = true,
        show_line = true,
        prompt_prefix = " References :: ",
        layout_config = {
            preview_width = 0.45,
        }
    })
end

local function telescope_lsp_document_symbols()
    require("telescope.builtin").lsp_document_symbols({
        prompt_prefix = " Document Symbols :: "
    })
end

local function telescope_lsp_workspace_symbols()
    require("telescope.builtin").lsp_workspace_symbols({
        prompt_prefix = " Workspace Symbols :: "
    })
end

local attach = function(client, bufnr, alt_keys)
    local opts = { buffer = bufnr }
    local frop = vim.tbl_deep_extend("force", { desc = "references" }, opts)
    local fsop = vim.tbl_deep_extend("force", { desc = "document symbols" }, opts)
    local fSop = vim.tbl_deep_extend("force", { desc = "workspace symbols" }, opts)
    vim.keymap.set("n", "<leader>fr", alt_keys and alt_keys.telescope_references  or telescope.references,            frop)
    vim.keymap.set("n", "<leader>ca", alt_keys and alt_keys.code_action           or vim.lsp.buf.code_action,         opts)
    vim.keymap.set("n", "<leader>cr", alt_keys and alt_keys.codelens_run          or vim.lsp.codelens.run,            opts)
    vim.keymap.set("n", "<leader>cc", alt_keys and alt_keys.rename                or vim.lsp.buf.rename,              opts)
    vim.keymap.set("n", "<c-]>",      alt_keys and alt_keys.definition            or vim.lsp.buf.definition,          opts)
    vim.keymap.set("n", "K",          alt_keys and alt_keys.hover                 or vim.lsp.buf.hover,               opts)
    vim.keymap.set("n", "<leader>fs", alt_keys and alt_keys.lsp_document_symbols  or telescope.lsp_document_symbols,  fsop)
    vim.keymap.set("n", "<leader>fS", alt_keys and alt_keys.lsp_workspace_symbols or telescope.lsp_workspace_symbols, fSop)
    if not package.loaded["lsp_signature"] then
        vim.keymap.set("i", "<c-h>",      alt_keys and alt_keys.signature_help        or vim.lsp.buf.signature_help,      opts)
        vim.keymap.set("n", "gK",         alt_keys and alt_keys.signature_help        or vim.lsp.buf.signature_help,      opts)
    end

    vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr(#{timeout_ms:250})"
    vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
    client.server_capabilities.semanticTokensProvider = nil
    if client.server_capabilities.definitionProvider then
        vim.api.nvim_set_option_value("tagfunc", "v:lua.vim.lsp.tagfunc", { buf = bufnr })
    end

    -- they are being stoopid with code lenses
    local is_stoopid = function(elem)
        return client.name ~= elem
    end
    if vim.iter({ "omnisharp", "gopls", "templ" }):any(is_stoopid) then
        if client.server_capabilities.codeLensProvider then
            vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("code_lens", { clear = false }),
                buffer = bufnr,
                callback = function()
                    vim.lsp.codelens.refresh({ bufnr = bufnr })
                end
            })
        end
    end
end

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        if vim.b["alt_lsp_maps"] then
            attach(vim.lsp.get_client_by_id(ev.data.client_id), ev.buf, vim.b["alt_lsp_maps"])
        else
            attach(vim.lsp.get_client_by_id(ev.data.client_id), ev.buf)
        end
    end,
})

return {
    on_attach = attach,
    default_setup = function(server)
        lspconfig[server].setup({
            -- on_attach = function() end,
            capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                require("blink.cmp").get_lsp_capabilities(),
                lspconfig[server].capabilities or {}
            )
        })
    end,
    lua_ls = function()
        require("lspconfig").lua_ls.setup({
            on_attach = attach,
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
                            "${3rd}/busted/library",
                            "$HOME/.config/nvim/lua/",
                        },
                    }
                })
                client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
            end,
            settings = {
                Lua = {}
            }
        })
    end,
}
