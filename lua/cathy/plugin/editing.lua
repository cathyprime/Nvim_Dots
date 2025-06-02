return {
    {
        "kylechui/nvim-surround",
        event = "InsertEnter",
        opts = {
            keymaps = {
                insert = false,
                insert_line = false,
                normal = "s",
                normal_cur = "ss",
                normal_line = "S",
                normal_cur_line = "SS",
                visual = "s",
                visual_line = "S",
                delete = "sd",
                change = "sc",
                change_line = false,
            },
            surrounds = {
                T = {
                    add = function ()
                        local user_input = require("nvim-surround.config").get_input("Enter the HTML tag: ")
                        if user_input then
                            local element = user_input:match("^<?([^%s>]*)")
                            local attributes = user_input:match("^<?[^%s>]*%s+(.-)>?$")
                            local open = attributes and element .. " " .. attributes or element
                            local close = element
                            return { { "<" .. open .. ">" }, { "</" .. close .. ">" } }
                        end
                    end,
                    find = function ()
                        return require("nvim-surround.config").get_selection({ motion = "at" })
                    end,
                    delete = "^(%b<>)().-(%b<>)()$",
                    change = {
                        target = "^<([^%s<>]*)().-([^/]*)()>$",
                        replacement = function ()
                            local user_input = require("nvim-surround.config").get_input("Enter the HTML tag: ")
                            if user_input then
                                local element = user_input:match("^<?([^%s>]*)")
                                local attributes = user_input:match("^<?[^%s>]*%s+(.-)>?$")
                                local open = attributes and element .. " " .. attributes or element
                                local close = element
                                return { { open }, { close } }
                            end
                        end,
                    },
                },
                t = {
                    add = function ()
                        local type = require("nvim-surround.config").get_input("Enter the TYPE: ")
                        if type then
                            return { { type .. "<" }, { ">" }}
                        end
                    end,
                    find = function ()
                        local c = require("nvim-surround.config")
                        if vim.g.loaded_nvim_treesitter then
                            local selection = c.get_selection({
                                query = {
                                    capture = "@type.outer",
                                    type = "textobjects",
                                }
                            })
                            if selection then
                                return selection
                            end
                        end
                        return c.get_selection({ pattern = "[^=%s%<%>{}]+%b()" })
                    end,
                    delete = "^(.-%<)().-(%>)()$",
                    change = {
                        target = "^.-([%w_]+)()%<.-%>()()$",
                        replacement = function ()
                            local type = require("nvim-surround.config").get_input("Enter the type name: ")
                            if type then
                                return { { type }, { "" } }
                            end
                        end
                    }
                }
            }
        },
    },
    {
        "monaqa/dial.nvim",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        config = function ()
            local dial = require("cathy.config.dial")
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
        end
    },
    {
        "jake-stewart/multicursor.nvim",
        branch = "1.0",
        config = function ()
            local nx = { "n", "x" }
            local mc = require("multicursor-nvim")
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
        end,
    },
}
