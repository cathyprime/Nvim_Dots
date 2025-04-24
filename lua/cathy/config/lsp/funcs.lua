local references = function ()
    Snacks.picker.lsp_references({
        prompt = " References :: ",
        layouts = {
            ivy = {
                layout = {
                    box = "vertical",
                    backdrop = false,
                    row = -1,
                    width = 0,
                    height = 0.4,
                    border = "top",
                    title = "{live} {flags}",
                    title_pos = "left",
                    { win = "input", height = 1, border = "none" },
                    {
                        box = "horizontal",
                        { win = "list", border = "none" },
                        { win = "preview", title = "{preview}", width = 0.6, border = "left" },
                    },
                },
            }
        }
    })
end

local lsp_document_symbols = function ()
    Snacks.picker.lsp_symbols({ prompt = " Document Symbols :: " })
end

local lsp_workspace_symbols = function ()
    Snacks.picker.lsp_workspace_symbols({ prompt = " Workspace Symbols :: " })
end

local attach = function(client, bufnr, alt_keys)
    local opts = { buffer = bufnr }
    local frop = vim.tbl_deep_extend("force", { desc = "references" }, opts)
    local fsop = vim.tbl_deep_extend("force", { desc = "document symbols" }, opts)
    local fSop = vim.tbl_deep_extend("force", { desc = "workspace symbols" }, opts)
    vim.keymap.set("n", "<leader>fr", alt_keys and alt_keys.references            or references,                 frop)
    vim.keymap.set("n", "<leader>ca", alt_keys and alt_keys.code_action           or vim.lsp.buf.code_action,    opts)
    vim.keymap.set("n", "<leader>cr", alt_keys and alt_keys.codelens_run          or vim.lsp.codelens.run,       opts)
    vim.keymap.set("n", "<leader>cc", alt_keys and alt_keys.rename                or vim.lsp.buf.rename,         opts)
    vim.keymap.set("n", "<c-]>",      alt_keys and alt_keys.definition            or vim.lsp.buf.definition,     opts)
    vim.keymap.set("i", "<c-h>",      alt_keys and alt_keys.signature_help        or vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "K",          alt_keys and alt_keys.hover                 or vim.lsp.buf.hover,          opts)
    vim.keymap.set("n", "<leader>fs", alt_keys and alt_keys.lsp_document_symbols  or lsp_document_symbols,       fsop)
    vim.keymap.set("n", "<leader>fS", alt_keys and alt_keys.lsp_workspace_symbols or lsp_workspace_symbols,      fSop)

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
}
