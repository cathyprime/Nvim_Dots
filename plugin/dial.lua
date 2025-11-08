local ok, dial = prot_require "dial.config"
if not ok then
    return
end

dial = require("cathy.config.dial.helper")
require("dial.config").augends:register_group(dial.register_group)
require("dial.config").augends:on_filetype(dial.on_filetype)

local mani = function (...)
    pcall(require("dial.map").manipulate, ...)
end
vim.keymap.set("n", "<c-a>",  function () mani("increment", "normal")         end)
vim.keymap.set("n", "<c-x>",  function () mani("decrement", "normal")         end)
vim.keymap.set("n", "g<c-a>", function () mani("increment", "gnormal")        end)
vim.keymap.set("n", "g<c-x>", function () mani("decrement", "gnormal")        end)
vim.keymap.set("v", "<c-a>",  function () mani("increment", "visual")         end)
vim.keymap.set("v", "<c-x>",  function () mani("decrement", "visual")         end)
vim.keymap.set("v", "g<c-a>", function () mani("increment", "gvisual")        end)
vim.keymap.set("v", "g<c-x>", function () mani("decrement", "gvisual")        end)
vim.keymap.set("n", "<c-g>",  function () mani("increment", "normal", "case") end)
