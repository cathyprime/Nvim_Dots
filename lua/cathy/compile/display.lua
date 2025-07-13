local ns = vim.api.nvim_create_namespace("Magda_Compile_Mode")

local M = {}
local H = {
    hl_group = {
        ok =  "CompileModeOk",
        err = "CompileModeErr",
        file = "CompileModeFile"
    },
}

local from_hl = function (hl_group)
    return function (opts)
        vim.defer_fn(function ()
            vim.hl.range(
                opts.bufnr,
                ns,
                hl_group,
                { opts.linenr, opts.start },
                { opts.linenr, opts.stop },
                { inclusive = false }
            )
        end, 50)
    end
end

M.range = {
    file = from_hl(H.hl_group.file)
}

if vim.fn.hlexists(H.hl_group.ok) == 0 then
    vim.api.nvim_set_hl(0, H.hl_group.ok, { link = "DiffAdd" })
end

if vim.fn.hlexists(H.hl_group.err) == 0 then
    vim.api.nvim_set_hl(0, H.hl_group.err, { link = "DiffDelete" })
end

if vim.fn.hlexists(H.hl_group.file) == 0 then
    local hl = vim.api.nvim_get_hl(0, { name = "DiagnosticError" })
    hl.underline = true
    vim.api.nvim_set_hl(0, H.hl_group.file, hl)
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

function M.quickfixtextfunc(info)
    local qf = vim.fn.getqflist({ id = info.id, all = 1 })
    local items = qf.items
    local l = {}

    for idx = info.start_idx - 1, info.end_idx - 1 do
        local item = items[idx + 1]

        local filename = ""
        if item.bufnr and item.bufnr > 0 then
            filename = vim.fn.bufname(item.bufnr)
        end

        if (item.text or ""):match("^%s*$") and (filename == "" or not item.lnum or item.lnum == 0) then
            table.insert(l, " ")
        else
            local parts = {}

            if filename ~= "" then
                table.insert(parts, filename)
            end
            if item.lnum and item.lnum > 0 then
                table.insert(parts, tostring(item.lnum))
            end
            if item.col and item.col > 0 then
                table.insert(parts, tostring(item.col))
            end


            local line
            if #parts > 0 then
                local parts_str = table.concat(parts, ":")
                line = parts_str .. ":" .. (item.text or "")
                M.range.file {
                    bufnr = qf.qfbufnr,
                    start = 0,
                    stop = #parts_str,
                    linenr = idx
                }
            else
                line = item.text or ""
            end

            table.insert(l, line)
        end
    end

    return l
end

return M
