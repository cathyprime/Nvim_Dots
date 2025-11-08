local ok, surround = prot_require "nvim-surround"
if not ok then
    return
end

surround.setup({
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
})
