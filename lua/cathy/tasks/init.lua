local i = require("cathy.tasks.utils.internal")
local cache = i.cache

local epic_code = [[return require("cathy.tasks.utils").input("epic", "Enter your gamer value")]]

local task = assert(loadstring(epic_code))

-- cache.set("tasks", "epic_task", task)
--
-- cache("tasks", "epic_task") -- no value
-- cache.inspect()
-- cache("tasks", "epic_task") -- value from previous input


local new_task = function ()
    vim.ui.input({ prompt = "New task name" }, function (input)
        if not input then
            return
        end

        local bufnr = i.create_task_buffer()
        i.prepare_buffer {
            bufnr = bufnr,
            name = input
        }
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { epic_code })
        i.open_task_window(bufnr, input)
    end)
end

-- new_task()
-- vim.cmd(cache("tasks", "new task"))
for k, v in pairs(cache.get()) do
    print("key:", k, "value:", type(v))
end
