local function augroup(name)
    return vim.api.nvim_create_augroup(string.format("Magda_%s", name), { clear = true })
end

local save_sudo = function (e)
    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = e.buf,
        callback = function ()
            if vim.fn.expand("%"):match "^oil://.*" then
                return
            end
            if require("cathy.utils").sudo_write() then
                vim.bo[e.buf].modified = false
                if vim.bo[e.buf].readonly then
                    vim.bo[e.buf].readonly = false
                end
            end
        end
    })
end

vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function(e)
        if vim.fn.expand("%"):match "^oil://.*" then
            return
        end
        if not require("cathy.utils").cur_buffer_path():match("^" .. os.getenv("HOME")) then
            vim.opt_local.modifiable = false
            save_sudo(e)
            return
        end
        if require("cathy.utils").cur_buffer_path():match("%.cargo") or vim.fn.expand("%:p"):match("%.rustup") then
            vim.opt_local.modifiable = false
        end
    end,
})

-- generate spell files if missing
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function ()
        local path = vim.fn.expand "~/.config/nvim/spell/"
        local download_spellfile = function (lang, cb)
            vim.system({
                "wget",
                "-P",
                path,
                "https://ftp.nluug.nl/pub/vim/runtime/spell/" .. lang .. "utf-8.spl"
            }, {}, cb)
        end
        local filter_bins = function (f)
            return not f:match "%.spl"
        end
        local confirmed = nil
        local work = function (f)
            local full_f = path .. f
            if not vim.uv.fs_stat(full_f .. ".spl") then
                if confirmed == nil then
                    confirmed = vim.fn.confirm("Download spell files?", "&Yes\n&No")
                end
                local pos = f:find "%.utf%-8%.add"
                local lang = f:sub(1, pos)
                if confirmed == 1 then
                    download_spellfile(lang, vim.schedule_wrap(function ()
                        vim.cmd.mkspell(full_f)
                    end))
                else
                    vim.cmd.mkspell(full_f)
                end
            end
        end
        local spell_files = vim.fs.dir(path)
        vim.iter(spell_files):filter(filter_bins):each(work)
    end
})

-- options.vim
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "options.vim",
    group = augroup("options_trail_space"),
    callback = function()
        vim.b.minitrailspace_disable = true
    end,
})

-- start minibuffer
vim.api.nvim_create_autocmd("CmdwinEnter", {
    once = false,
    group = augroup("minibuffer"),
    callback = function()
        vim.opt_local.filetype = "minibuffer"
    end
})

-- Load view
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = augroup("load_view"),
    pattern = "*.*",
    callback = function() vim.cmd.loadview({ mods = { emsg_silent = true } }) end,
})

-- terminal settings
vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup("terminal"),
    callback = function()
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.scrolloff = 0
        vim.opt_local.number = false
        vim.opt_local.spell = false
        vim.cmd("normal G")
    end
})

-- highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        vim.hl.on_yank({ higroup = "Yank" })
    end,
})

-- close with q
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "help",
        "query",
        "man",
        "tsplayground",
        "checkhealth",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", function()
            local ok, _ = pcall(vim.cmd.close)
            if not ok then
                vim.cmd.bdelete()
            end
        end, { buffer = event.buf, silent = true, noremap = true, nowait = true })
    end,
})

-- create folder in-between
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = augroup("auto_create_dir"),
    callback = function(event)
        if event.match:match("^%w%w+://") then
            return
        end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

-- set filetype c for header and .c files instead of c++
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    group = augroup("c_filetypes"),
    once = false,
    pattern = {"*.c", "*.h"},
    command = "set ft=c",
})

local trans = setmetatable({
    cs = "c_sharp"
}, { __index = function (tbl, key) return key end})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(e)
        local ts = require "nvim-treesitter"
        local has = function (what)
            return function (it)
                return it == what
            end
        end
        local parser = trans[e.match]
        if vim.iter(ts.get_installed()):any(has(parser)) then
            vim.treesitter.start()
            vim.opt.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            return
        end
        if vim.iter(ts.get_available()):any(has(parser)) then
            vim.cmd.TSInstall(parser)
        end
    end,
})
