local from_snacks = require("cathy.utils.snacks.from_snacks")
local ns = vim.api.nvim_create_namespace("Magda_Find_File")
local home = os.getenv("HOME")

return function (opts)
    local cache = {}
    local prev_wd
    local extmark_id = nil

    local function get_files(path)
        if cache[path] then
            return cache[path]
        end
        local obj = vim.system({ "fd", "-L", "--exact-depth=1", "-HI", '.', path }, { text = true }):wait()
        local stdout = vim.split(obj.stdout, "\n", { trimempty = true, plain = true })
        table.insert(stdout, 1, path .. ".")
        table.insert(stdout, 2, path .. "..")
        cache[path] = stdout
        return cache[path]
    end
    local set_prompt = function (picker, new_prompt)
        picker:set_cwd(new_prompt)
        vim.api.nvim_buf_set_lines(picker.input.win.buf, 0, -1, false, { new_prompt })
        if new_prompt:match(home .. ".*") then
            extmark_id = vim.api.nvim_buf_set_extmark(
                picker.input.win.buf, ns, 0, 0, {
                    id = extmark_id,
                    end_col = #home,
                    hl_group = "Normal",
                    virt_text = {
                        { "~", "Normal" }
                    },
                    virt_text_pos = "inline",
                    conceal = "",
                }
            )
        end
        vim.api.nvim_win_set_cursor(picker.input.win.win, { 1, #new_prompt })
        picker:find()
    end
    local get_prompt = function (picker)
        return vim.api.nvim_buf_get_lines(picker.input.win.buf, 0, -1, false)[1]
    end

    return function()
        return Snacks.picker({
            layout = {
                preview = false
            },
            prompt = opts.prompt,
            pattern = require("cathy.utils").cur_buffer_path() .. "/",
            on_show = function (picker)
                vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                    buffer = picker.input.win.buf,
                    callback = function()
                        local prompt = get_prompt(picker)
                        local pos = prompt:match(".*()/")
                        local cursor = vim.api.nvim_win_get_cursor(picker.input.win.win)
                        if cursor[2] < pos then
                            vim.api.nvim_win_set_cursor(picker.input.win.win, { 1, pos })
                        end
                    end,
                })
            end,
            on_change = function (picker)
                local prompt = get_prompt(picker)
                if prompt == "" then
                    prompt = "/"
                end
                if prompt:match(home .. ".*") then
                    extmark_id = vim.api.nvim_buf_set_extmark(
                        picker.input.win.buf, ns, 0, 0, {
                            id = extmark_id,
                            end_col = #home,
                            hl_group = "Normal",
                            virt_text = {
                                { "~", "Normal" }
                            },
                            virt_text_pos = "inline",
                            conceal = "",
                        }
                    )
                end
                if picker:cwd() ~= prev_wd then
                    prev_wd = picker:cwd()
                    prompt = vim.fn.fnamemodify(prompt, ":h") .. "/"
                    picker:set_cwd(prompt)
                    picker:find()
                end
            end,
            finder = function (ctx)
                local picker = Snacks.picker.get({ tab = true })[1]
                local cwd
                if not picker then
                    cwd = require("cathy.utils").cur_buffer_path()
                else
                    cwd = picker:cwd()
                end
                if cache[cwd] then
                    return cache[cwd]
                end

                local items = {}
                for i, item in ipairs(get_files(cwd)) do
                    local ft = vim.fn.fnamemodify(item, ":p:t:e")
                    if ft == "" then
                        ft = nil
                    end
                    table.insert(items, {
                        idx = i,
                        file = item,
                        text = item,
                        ft = ft,
                    })
                end
                cache[cwd] = items
                return items
            end,
            win = {
                input = {
                    keys = {
                        ["<tab>"] = { "complete_from_selected", mode = { "i", "n" }, desc = "Complete from selected entry" },
                        ["<c-h>"] = { "go_home", mode = { "i" }, desc = "Go to $HOME directory" },
                        ["<c-w>"] = { "delete_word", mode = { "i" }, desc = "Delete word" },
                        ["<c-bs>"] = { "delete_word", mode = { "i" }, desc = "Delete word" },
                        ["<bs>"] = { "delete_char_or_path", mode = { "i" }, desc = "backspace" },
                    },
                    wo = {
                        conceallevel = 3,
                        concealcursor = "nivc",
                    }
                },
            },
            actions = {
                go_home = function (picker)
                    set_prompt(picker, os.getenv("HOME") .. "/")
                end,
                delete_word = function (picker)
                    local prompt = get_prompt(picker)
                    if string.sub(prompt, -1) == "/" then
                        if #prompt > 1 then
                            local pos = string.match(string.sub(prompt, 1, -2), ".*()/")
                            set_prompt(picker, string.sub(prompt, 1, pos))
                        end
                    else
                        local last_slash = string.match(prompt, ".*()/")
                        set_prompt(picker, string.sub(prompt, 1, last_slash))
                    end
                end,
                delete_char_or_path = function (picker)
                    local prompt = get_prompt(picker)
                    local cursor = vim.api.nvim_win_get_cursor(picker.input.win.win)
                    local last_slash = prompt:match(".*()/")
                    if prompt:sub(cursor[2], cursor[2]) == "/" then
                        local pos = string.match(string.sub(prompt, 1, cursor[2] - 1), ".*()/")
                        local new_prompt = string.sub(prompt, 1, pos)
                        set_prompt(picker, new_prompt)
                        return
                    end
                    vim.fn.feedkeys(vim.keycode"<bs>", "n")
                end,
                complete_from_selected = function (picker, item)
                    if not item then
                        return
                    end
                    local display = item.file
                    if display:match "%.%.$" then
                        local new_path = vim.fs.normalize(item.file)
                        if #new_path ~= 1 then
                            new_path = new_path .. "/"
                        end
                        local buf = picker.input.win.buf
                        set_prompt(picker, new_path)
                        return
                    end
                    if display:match "%.$" then
                        return
                    end

                    local buf = picker.input.win.buf
                    set_prompt(picker, item.file:gsub("//", "/"))
                end
            },
            format = function(item, _)
                local ret = {}
                local fname = item.file
                local a = Snacks.picker.util.align
                local icon, icon_hl = Snacks.util.icon(item.ft, item.ft and "filetype" or "directory")

                if string.sub(fname, -1) == "/" then
                    fname = vim.fn.fnamemodify(fname, ":h:t") .. "/"
                else
                    fname = vim.fn.fnamemodify(fname, ":t")
                end

                ret[#ret + 1] = { a(icon, 3), icon_hl }
                ret[#ret + 1] = { a(fname, 20) }

                return ret
            end,
            confirm = function(picker, item)
                local result
                if not item.match_topk then
                    result = get_prompt(picker)
                else
                    result = item.text
                end
                picker:close()
                local cd_chars = {
                    ["/"] = true,
                    ["."] = true,
                }
                if cd_chars[string.sub(result, -1)] then
                    vim.cmd.cd(result)
                end
                vim.cmd.edit(result)
            end,
        })
    end
end

