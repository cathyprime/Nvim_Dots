local cache = nil
local padding = string.rep(" ", 8)

local function set_lines(buf, lines)
    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end

local function new_buf(lines)
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
    vim.api.nvim_buf_set_name(buf, "Documentation")
    return buf
end

local function display_in_split(buf)
    local target_win = nil

    for win in pairs(vim.api.nvim_list_wins()) do
        local b = vim.api.nvim_win_get_buf(vim.fn.win_getid(win))
        if b == buf then
            target_win = vim.fn.win_getid(win)
        end
    end

    if target_win ~= nil then
        vim.api.nvim_set_current_win(target_win)
    else
        vim.cmd("sp")
        target_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(target_win, buf)
    end

    vim.api.nvim_set_option_value("conceallevel", 3, { win = target_win })
    vim.api.nvim_set_option_value("concealcursor", "nvic", { win = target_win })
    vim.api.nvim_set_option_value("relativenumber", false, { win = target_win })
    vim.api.nvim_set_option_value("number", false, { win = target_win })
    vim.api.nvim_set_option_value("statuscolumn", padding, { win = target_win })
    vim.api.nvim_set_option_value("wrap", false, { win = target_win })
end

return {
    hover = function(small_hover)
        return function(_, result, ctx, config)
            local lines = vim.split(result.contents.value:gsub("\n\n\n", "\n"):gsub("\n\n", "\n"), "\n")

            if #lines <= 10 then
                small_hover(nil, result, ctx, config)
                return
            end

            if cache == nil or not vim.api.nvim_buf_is_valid(cache) then
                cache = new_buf(lines)
            else
                set_lines(cache, lines)
            end

            display_in_split(cache)
        end
    end
}
