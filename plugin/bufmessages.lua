local BUFNAME = "Messages"

local old_messages = {}

---@alias bufnr integer

---@param bufnr bufnr
local function set_lines(bufnr)
    local new_messages = vim.api.nvim_cmd({ cmd = "messages" }, { output = true })
    if new_messages == "" then
        return
    end
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    local lines = vim.split(new_messages, "\n")
    if #lines <= #old_messages then
        return
    end
    old_lines = lines

    local result = {}
    local empty_line_count = 0
    local in_content = false

    for _, line in ipairs(lines) do
        if line == "" then
            if in_content then
                empty_line_count = empty_line_count + 1
            end
        else
            if empty_line_count > 3 then
                table.insert(result, "")
                if empty_line_count - 3 == 1 then
                    table.insert(result, "--> folded 1 empty line <--")
                else
                    table.insert(result, "--> folded " .. (empty_line_count - 3) .. " empty lines <--")
                end
                table.insert(result, "")
            end
            empty_line_count = 0
            in_content = true
            table.insert(result, line)
        end
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result)
end

---@param bufnr bufnr
---@return nil
local function set_options(bufnr)
    vim.api.nvim_buf_set_name(bufnr, BUFNAME)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
    vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
    vim.api.nvim_set_option_value("buflisted", false, { buf = bufnr })
    vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
    vim.keymap.set("n", "q", "<cmd>bd!<cr>", { buffer = bufnr, silent = true })
    local timer = vim.uv.new_timer()
    timer:start(1000, 1000, vim.schedule_wrap(function()
        set_lines(bufnr)
    end))
    vim.api.nvim_create_autocmd({ "BufDelete", "BufUnload" }, {
        buffer = bufnr,
        callback = function()
            timer:stop()
            timer:close()
        end,
    })
end

---@return bufnr
local function create_messages_buffer()
    local bufnr = vim.api.nvim_create_buf(false, true)
    set_options(bufnr)
    set_lines(bufnr)
    return bufnr
end

---@param name string
---@return bufnr|nil
local function find_buffer_by_name(name)
    local bufs = vim.api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
        if vim.fn.bufname(buf) == name then
            return buf
        end
    end
end

vim.api.nvim_create_user_command(
    "Messages",
    function(opts)
        local buf = find_buffer_by_name(BUFNAME)
        if buf == nil then
            buf = create_messages_buffer()
            vim.cmd(string.format(opts.mods.." sp | keepalt buffer %s", buf))
        else
            set_lines(buf)
            local wins = vim.api.nvim_tabpage_list_wins(0)
            local found = false
            local win_id = nil
            for _, win in ipairs(wins) do
                if vim.api.nvim_win_get_buf(win) == buf then
                    win_id = win
                    break
                end
            end
            if win_id ~= nil then
                vim.api.nvim_set_current_win(win_id)
                vim.api.nvim_win_set_cursor(0, { vim.fn.line('$'), 0 })
            else
                vim.cmd(string.format(opts.mods.." sp | keepalt buffer %s", buf))
            end
        end
    end,
    {}
)
