local ns = vim.api.nvim_create_namespace("Magda_Compile_Mode")

local M = {}
local H = {
    hl_group = {
        ok =  "CompileModeOk",
        err = "CompileModeErr"
    },
}

if vim.fn.hlexists(H.hl_group.ok) == 0 then
    vim.api.nvim_set_hl(0, H.hl_group.ok, { link = "DiffAdd" })
end

if vim.fn.hlexists(H.hl_group.err) == 0 then
    vim.api.nvim_set_hl(0, H.hl_group.err, { link = "DiffDelete" })
end

function M.color_ok(len, start)
    return function (bufnr, linenr)
        vim.hl.range(bufnr, ns, H.hl_group.ok, { linenr, start }, { linenr, start + len }, { inclusive = false })
    end
end

function M.color_err(len, start)
    return function (bufnr, linenr)
        vim.hl.range(bufnr, ns, H.hl_group.err, { linenr, start }, { linenr, start + len }, { inclusive = false })
    end
end

function M.clear_ns(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

return M
