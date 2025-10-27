local M = {
    hl_group = {
        ok =  "CompileModeOk",
        err = "CompileModeErr",
        file = "CompileModeFile",
        underline = "CompileModeUnderline"
    },
}

M.ns = vim.api.nvim_create_namespace("Magda_Compile_Mode")

if vim.fn.hlexists(M.hl_group.ok) == 0 then
    vim.api.nvim_set_hl(0, M.hl_group.ok, { link = "DiffAdd" })
end

if vim.fn.hlexists(M.hl_group.err) == 0 then
    vim.api.nvim_set_hl(0, M.hl_group.err, { link = "DiffDelete" })
end

if vim.fn.hlexists(M.hl_group.file) == 0 then
    local hl = vim.api.nvim_get_hl(0, { name = "DiagnosticError" })
    hl.underline = true
    vim.api.nvim_set_hl(0, M.hl_group.file, hl)
end

if vim.fn.hlexists(M.hl_group.underline) == 0 then
    local hl = { underline = true }
    vim.api.nvim_set_hl(0, M.hl_group.underline, { underline = true })
end

function M.get_group(code)
    if code == 0 then
        return M.hl_group.ok
    end
    return M.hl_group.err
end

function M.clear_ns(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, M.ns, 0, -1)
end

return M
