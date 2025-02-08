local from_snacks = require("cathy.utils.snacks.from_snacks")

return function (opts)
    local cache = {}
    local prev_wd

    local function get_files(path)
        if cache[path] then
            return cache[path]
        end
        local obj = vim.system({ "fd", "-L", "--exact-depth=1", "-HI", '.', path }, { text = true }):wait()
        local stdout = vim.split(obj.stdout, "\n", { trimempty = true, plain = true })
        table.insert(stdout, 1, path .. ".")
        table.insert(stdout, 2, path .. "..")
        cache[path] = stdout
        return stdout
    end
    local set_prompt = function (picker, new_prompt)
        picker:set_cwd(new_prompt)
        vim.api.nvim_buf_set_lines(picker.input.win.buf, 0, -1, false, { new_prompt })
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
            on_change = function (picker)
                local prompt = picker:filter().pattern
                if prompt == "" then
                    prompt = "/"
                end
                if picker:cwd() ~= prev_wd then
                    prev_wd = picker:cwd()
                    prompt = vim.fn.fnamemodify(prompt, ":h") .. "/"
                    picker:set_cwd(prompt)
                    picker:find()
                end
            end,
            on_show = function (picker)
                picker:set_cwd(vim.uv.cwd() .. "/")
            end,
            pattern = vim.uv.cwd() .. "/",
            finder = function (ctx)
                local picker = Snacks.picker.get()[1]
                local cwd = picker:cwd()
                if cache[cwd] then
                    return cache[cwd]
                end

                local items = {}
                for i, item in ipairs(get_files(picker:cwd())) do
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
                        ["<c-h>"] = { "c_h", mode = { "i" }, desc = "Go to $HOME directory" },
                        ["<c-w>"] = { "c_w", mode = { "i" }, desc = "delete till /" },
                        ["<bs>"] = { "backspace", mode = { "i" }, desc = "backspace" },
                    },
                },
            },
            actions = {
                c_h = function (picker)
                    set_prompt(picker, os.getenv("HOME") .. "/")
                end,
                c_w = function (picker)
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
                backspace = function (picker)
                    local prompt = get_prompt(picker)
                    if string.sub(prompt, -1) == "/" then
                        local pos = string.match(string.sub(prompt, 1, -2), ".*()/")
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
                    set_prompt(picker, item.file)
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
                    result = picker:filter().pattern
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

