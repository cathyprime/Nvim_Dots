local Errors = {}

function Errors.new()
    return setmetatable({}, { __index = Errors })
end

local ns = vim.api.nvim_create_namespace("Compile_Mode_Errors")
vim.fn.sign_define("CompileErrorSign", {
    text = "E",
    texthl = "DiagnosticError",
})

local function set_compiler(compiler)
    return pcall(vim.cmd.compiler, {
        args = { compiler },
        bang = true,
        mods = { silent = true }
    })
end

function Errors:set_compiler_from_cmd(cmd)
    vim.api.nvim_create_autocmd("User", {
        pattern = "CompileFinished",
        once = true,
        callback = function ()
            set_compiler "make"
        end
    })
    local compiler = cmd:match("^(%S+)")
    if not compiler then
        set_compiler "make"
        return
    end

    local ok = set_compiler(compiler)
    if not ok then
        set_compiler "make"
    end
end

function Errors:attach(bufid)
    self.buffer = bufid
    vim.api.nvim_create_autocmd("User", {
        pattern = "CompileFinished",
        callback = function ()
            vim.fn.setqflist({}, "r", { items = {} })
        end
    })
    vim.api.nvim_create_autocmd("User", {
        pattern = "CompileDataAppended",
        callback = function (ev)
            local buf = ev.data.buf
            if bufid ~= buf then
                return
            end
            local range = ev.data.affected_range

            if range[1] == 1 and range[2] == 2 then
                return
            end

            local lines = vim.api.nvim_buf_get_lines(buf, range[1], range[2], false)

            vim.fn.setqflist({}, "r", { lines = lines })
            local qf_items = vim.fn.getqflist({ items = 0 }).items or {}

            for i, item in ipairs(qf_items) do
                if item.valid == 1 then
                    local line_idx = range[1] + i
                    self[line_idx] = item
                    vim.fn.sign_place(
                        0,
                        "CompileErrorSigns",
                        "CompileErrorSign",
                        buf,
                        { lnum = line_idx }
                    )
                end
            end
        end
    })
end

function Errors:clear()
    for key in pairs(self) do
        self[key] = nil
    end
end

return Errors
