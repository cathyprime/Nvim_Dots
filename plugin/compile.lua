local last_args = nil
local last_process = nil
local default_split = "below"

local function open_tool(tool_cmd, mods)
    last_process = nil

    if not tool_cmd or tool_cmd == "" then
        vim.notify("Please specify a tool command", vim.log.levels.ERROR)
        return
    end

    tool_cmd = tool_cmd:gsub("&%s*$", "")
    mods = mods or {}
    local buf = vim.api.nvim_create_buf(false, true)
    local win_config = {
        win = 0,
    }

    if mods.vertical then
        win_config.vertical = true
        win_config.split = mods.split or default_split
    elseif mods.split then
        win_config.vertical = false
        win_config.split = mods.split
    else
        win_config.vertical = true
        win_config.split = default_split
    end

    if win_config.split == "" then
        win_config.split = default_split
    end
    local win = vim.api.nvim_open_win(buf, true, win_config)

    vim.fn.termopen(tool_cmd)
    vim.api.nvim_cmd({ cmd = 'startinsert' }, {})
end

vim.api.nvim_create_user_command(
    "Compile",
    function (e)
        local on_confirm = function (input)
            if not input then return end
            last_args = input
            local expanded_cmd = vim.fn.expandcmd(input)
            if expanded_cmd:sub(-1) == '&' and expanded_cmd:sub(-2, -2) ~= '&' then
                open_tool(expanded_cmd, {})
                return
            end
            last_process = require("cathy.compile") {
                cmd = expanded_cmd
            }
        end
        vim.ui.input(
            {
                prompt = "Compile Command :: ",
                default = last_args,
                completion = "shellcmdline"
            },
            on_confirm
        )
    end,
    {
        nargs = 0
    }
)

vim.api.nvim_create_user_command(
    "Recompile",
    function ()
        if not last_args then
            vim.notify("No previous command!", vim.log.levels.ERROR)
            return
        end

        if last_args:sub(-1) == "&" then
            local expanded_cmd = vim.fn.expandcmd(last_args)
            open_tool(expanded_cmd, {})
            return
        end

        if not last_process then
            vim.notify("No previous process!", vim.log.levels.ERROR)
            return
        end
        if last_process.is_running then
            return
        end
        last_process.e:clear()
        last_process.buf:replace_lines(0, - 1, {})
        last_process.buf._ends_with_newline = false
        last_process:start(
            vim.b[last_process.buf.bufid].executor,
            vim.b[last_process.buf.bufid].exec_opts
        )
    end,
    {
        nargs = 0
    }
)

vim.api.nvim_create_user_command(
    "Seethe",
    function ()
        if not last_process then
            vim.notify("No previous command!", vim.log.levels.ERROR)
            return
        end
        last_process:show(true)
    end,
    {}
)

vim.keymap.set("n", "<leader>q", "<cmd>Seethe<cr>", { silent = true })
vim.keymap.set("n", "'<cr>", "<cmd>Recompile<cr>", { silent = true })
vim.keymap.set("n", "'<space>", "<cmd>Compile<cr>", { silent = false })
