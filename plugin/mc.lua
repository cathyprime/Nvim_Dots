local ok, mc = prot_require "multicursor-nvim"
if not ok then
    return
end

local nx = { "n", "x" }
mc.setup()

vim.keymap.set(nx, "<c-n>",      function () mc.addCursor("*")  end)
vim.keymap.set(nx, "<c-p>",      function () mc.addCursor("#")  end)
vim.keymap.set(nx, "<c-s><c-n>", function () mc.skipCursor("*") end)
vim.keymap.set(nx, "<c-s><c-p>", function () mc.skipCursor("#") end)

vim.keymap.set("n", "<leader>gv", mc.restoreCursors)
vim.keymap.set("x", "<c-q>",      mc.visualToCursors)
vim.keymap.set("x", "m",          mc.matchCursors)
vim.keymap.set("x", "M",          mc.splitCursors)

vim.keymap.set(nx, "<c-i>", mc.jumpForward)
vim.keymap.set(nx, "<c-o>", mc.jumpBackward)
vim.keymap.set(nx, "ga", mc.operator)

mc.addKeymapLayer(function (layer_set)
    layer_set("n", "ga",    mc.alignCursors)
    layer_set("n", "<esc>", mc.clearCursors)
    layer_set("n", "<c-j>", mc.nextCursor)
    layer_set("n", "<c-k>", mc.prevCursor)
    layer_set("n", "<c-a>", mc.sequenceIncrement)
    layer_set("n", "<c-x>", mc.sequenceDecrement)
end)
