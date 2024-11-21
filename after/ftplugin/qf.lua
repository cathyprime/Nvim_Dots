vim.opt_local.spell = false

local function cmd(command)
    return function()
        local count = vim.v.count
        if count ~= 0 then
            command = command .. " " .. count
        end
        print(count)
        return string.format("<cmd>silent! unsilent %s<cr>", command)
    end
end

local loc_qf = function(opts)
    if vim.fn.getwininfo(vim.fn.win_getid())[1]['loclist'] == 1 then
        return opts.on_loc()
    else
        return opts.on_qf()
    end
end

-- vim.keymap.set("n", "<", cmd("colder"), { buffer = true, silent = true, expr = true })
-- vim.keymap.set("n", ">", cmd("cnewer"), { buffer = true, silent = true, expr = true })
vim.keymap.set("n", "o", function()
    return loc_qf({
        on_qf = function()
            return "<cr><cmd>cclose<cr>"
        end,
        on_loc = function()
            return "<cr><cmd>lclose<cr>"
        end
    })
end, { buffer = true, silent = true, expr = true })

vim.keymap.set("n", "q", function()
    return loc_qf({
        on_qf = function()
            return "<cmd>cclose<cr>"
        end,
        on_loc = function()
            return "<cmd>lclose<cr>"
        end
    })
end, { buffer = true, silent = true, expr = true })

vim.keymap.set("x", "R", ":Reject<cr>")
vim.keymap.set("x", "K", ":Keep<cr>")

vim.keymap.set("n", "R", function()
    vim.o.operatorfunc = "v:lua.require'cathy.repeats'.reject"
    vim.cmd.normal "g@l"
end, { buffer = true, silent = true })

vim.keymap.set("n", "K", function()
    vim.o.operatorfunc = "v:lua.require'cathy.repeats'.keep"
    vim.cmd.normal "g@l"
end, { buffer = true, silent = true })

vim.keymap.set("n", "gR", function()
    vim.o.operatorfunc = "v:lua.require'cathy.repeats'.g_reject"
    vim.cmd.normal "g@l"
end, { buffer = true, silent = true })

vim.keymap.set("n", "gK",  function()
    vim.o.operatorfunc = "v:lua.require'cathy.repeats'.g_keep"
    vim.cmd.normal "g@l"
end, { buffer = true, silent = true })
