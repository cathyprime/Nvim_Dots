local fs = require("cathy.tasks.utils.fs")
local i = require("cathy.tasks.utils.internal")
local cache = require("cathy.tasks.utils.cache")
local t = cache.types

local get_prompt = function (picker)
    return vim.api.nvim_buf_get_lines(picker.input.win.buf, 0, -1, false)[1]
end

local new_task = function (name)
    if not name then
        return
    end

    local result = vim.fn.confirm("Create global task?", "&Yes\n&No\n&Cancel")
    if result == 3 then
        return
    end

    local bufnr = i.create_task_buffer()
    i.prepare_buffer {
        bufnr = bufnr,
        name = name,
        cwd = result == 1 and "global" or vim.uv.cwd(),
        kind = result == 1 and t.global or t.tasks
    }
    i.open_task_window(bufnr, name)
end

local edit_task = function (item)
    local dir = item.kind == t.global and "global" or item.task_dir
    local file = fs.task_file(dir, item.task_name)
    local lines = vim.fn.readfile(file)

    local bufnr = i.create_task_buffer()
    i.prepare_buffer {
        bufnr = bufnr,
        name = item.task_name,
        kind = item.kind,
        cwd = dir,
    }
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
    i.open_task_window(bufnr, item.task_name)
end

local create_new_task = function ()
    vim.ui.input({ prompt = "Task name" }, new_task)
end

local delete_task = function (item)
    local dir = item.kind == t.global and "global" or item.task_dir
    local file = fs.task_file(dir, item.task_name)
    vim.fs.rm(file, { force = true })
    cache.set(item.kind, item.task_name, nil)
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
        show_empty = true,
        layout = {
            preview = false
        },
        actions = {
            create_task_from_prompt = function (picker)
                local prompt = get_prompt(picker)
                picker:close()
                new_task(prompt)
            end,
            edit_task = function (picker, item)
                picker:close()
                if not item then
                    return
                end
                edit_task(item)
            end,
            delete_task = function (picker, item)
                if not item then
                    return
                end
                delete_task(item)
                picker:find()
            end
        },
        win = {
            input = {
                keys = {
                    ["<c-cr>"] = { "create_task_from_prompt", mode = { "i" }, desc = "Create task from prompt" },
                    ["<c-e>"] = { "edit_task", mode = { "i" }, desc = "Edit task" },
                    ["<c-x>"] = { "delete_task", mode = { "i" }, desc = "Delete task" }
                }
            }
        },
        finder = function ()
            local cwd = vim.uv.cwd()
            local format = function (label)
                local kind = label == "global" and t.global or t.tasks
                local task_dir = kind == t.global and "global" or cwd
                label = "[" .. label .. "] "
                return function (task_name)
                    return {
                        task_name = task_name,
                        text = label .. task_name,
                        task_dir = task_dir,
                        kind = kind
                    }
                end
            end
            local local_items = vim.iter(fs.get_tasks(cwd))
                :map(format("local"))
                :totable()
            local global_items = vim.iter(fs.get_tasks("global"))
                :map(format("global"))
                :totable()
            return vim.tbl_deep_extend("keep", local_items, global_items)
        end,
        confirm = function (picker, item)
            local prompt = get_prompt(picker)
            picker:close()
            if not item then
                new_task(prompt)
                return
            end
            local cmd = cache.run(item.kind, item.task_name)
            vim.cmd(assert(cmd, "no command?"))
        end,
    })
end

return pick
