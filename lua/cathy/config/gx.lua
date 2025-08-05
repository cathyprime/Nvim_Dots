local ok, gx = prot_require "gx"
if not ok then
    return
end

gx.setup()
vim.keymap.set("n", "gX", "<cmd>Browse<cr>")
