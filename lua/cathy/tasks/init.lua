local i = require("cathy.tasks.utils.internal")
local cache = i.cache
local t = i.cache_types

local get_prompt = function (picker)
    return vim.api.nvim_buf_get_lines(picker.input.win.buf, 0, -1, false)[1]
end

local new_task = function (name)
    if not name then
        return
    end

    local bufnr = i.create_task_buffer()
    i.prepare_buffer {
        bufnr = bufnr,
        name = name
    }
    i.open_task_window(bufnr, name)
end

local pick = function ()
    local cwd = vim.uv.cwd()
    Snacks.picker.pick({
        prompt = " Tasks :: ",
        matcher = {
            frecency = true,
        },
        source = "tasks",
        format = "text",
        finder = function ()
            local cwd = vim.uv.cwd()
            local format = function (label)
                local kind = label == "global" and t.global or t.tasks
                label = "[" .. label .. "] "
                return function (task_name)
                    return {
                        task_name = task_name,
                        text = label .. task_name,
                        task_dir = cwd,
                        kind = kind
                    }
                end
            end
            local local_items = vim.iter(i.get_tasks(cwd))
                :map(format("local"))
                :totable()
            local global_items = vim.iter(i.get_tasks("globals"))
                :map(format("global"))
                :totable()
            return vim.tbl_deep_extend("keep", local_items, global_items)
        end,
        confirm = function (picker, item)
            local prompt = get_prompt(picker)
            picker:close()
            if item then
                local cmd = cache(item.kind, item.task_name)
                if cmd then
                    vim.cmd(cmd)
                end
                return
            end
            new_task(prompt)
        end,
        layout = {
            preview = false
        },
    })
end

pick()
