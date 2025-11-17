local ok, grapple = prot_require "grapple"
if not ok then
    return
end

grapple.setup {
    scope = "git_branch"
}

local map = function (lhs, rhs, opts)
    if type(rhs) == "string" then
        rhs = ("<cmd>Grapple %s<cr>"):format(rhs)
    end
    if not opts then
        opts = { silent = true }
    else
        opts.silent = true
    end
    vim.keymap.set("n", lhs, rhs, opts)
end

map("<m-q>", "select index=1")
map("<m-w>", "select index=2")
map("<m-e>", "select index=3")
map("<m-r>", "select index=4")
map("<leader>a", "toggle")
map("<leader>e", function ()
    if vim.v.count == 0 then
        return "<cmd>Grapple toggle_tags<cr>"
    else
        return ("<cmd>Grapple select index=%s<cr>"):format(vim.v.count)
    end
end, { expr = true })
