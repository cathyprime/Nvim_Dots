local fs = require("cathy.tasks.utils.fs")
local cache = require("cathy.tasks.utils.cache")
local M = {}

function M.open_task_window(bufnr, name, size)
    size = size or 0.70

    local columns = vim.opt.columns:get()
    local lines = vim.opt.lines:get()
    local i_size = (1 - size) / 2

    local height = math.floor(lines   * size)
    local width  = math.floor(columns * size)
    local row    = math.floor(lines   * i_size)
    local col    = math.floor(columns * i_size)

    vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "single",
        title = name,
        title_pos = "center"
    })
end

function M.create_task_buffer()
    return vim.api.nvim_create_buf(false, true)
end

function M.prepare_buffer(opts)
    vim.bo[opts.bufnr].ft = "lua"
    vim.keymap.set("n", "q", function()
        local ok, _ = pcall(vim.cmd.close)
        if not ok then
            vim.cmd.bdelete()
        end
    end,
    {
        buffer = opts.bufnr,
        silent = true,
        noremap = true,
        nowait = true,
    })
    vim.api.nvim_create_autocmd({ "BufDelete", "BufHidden" }, {
        buffer = opts.bufnr,
        once = true,
        callback = function ()
            local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, true)
            fs.save_task(opts.name, opts.cwd or vim.uv.cwd(), lines)
            local str = table.concat(lines, "\n")
            local f = assert(loadstring(str), "failed to compile code")
            cache.set(opts.kind, opts.name, f)
        end
    })
end

return M
