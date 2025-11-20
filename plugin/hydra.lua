local ok, Hydra = prot_require "hydra"
if not ok then
    return
end

local statusline = {
    hint = {
        type = "statusline",
    }
}

Hydra({
    name = "Side scroll",
    mode = "n",
    body = "z",
    config = statusline,
    heads = {
        { "h", "5zh" },
        { "l", "5zl", { desc = "<-/->" } },
        { "H", "zH" },
        { "L", "zL", { desc = "half screen <-/->" } },
    },
})

Hydra({
    name = "resize window",
    mode = "n",
    body = "<C-w>",
    config = statusline,
    heads = {
        { "<", "<C-w><" },
        { ">", "<C-w>>", { desc = "width" } },
        { "+", "<C-w>+" },
        { "-", "<C-w>-", { desc = "height" } },
        { "=", "<C-w>=", { desc = "reset" } },
    },
})

---@type number
local scroll

local function scrolloff_toggle()
    if scroll == nil then
        scroll = vim.opt.scrolloff:get()
    end
    if vim.o.scrolloff == 0 then
        vim.opt["scrolloff"] = scroll
    else
        vim.o.scrolloff = 0
    end
end

local function boolean_switch(option)
    return function()
        vim.o[option] = not vim.o[option]
    end
end

local function virtual_edit()
    if vim.o.virtualedit == "" then
        vim.o.virtualedit = "all"
    else
        vim.o.virtualedit = ""
    end
end

local function fold_column()
    if vim.o.foldcolumn == "0" then
        vim.o.foldcolumn = "4"
    else
        vim.o.foldcolumn = "0"
    end
end

local function background()
    if vim.opt.background:get() == "light" then
        vim.opt.background = "dark"
    else
        vim.opt.background = "light"
    end
end

local function get_opt(opt, fmt)
    return function ()
        return string.format(fmt, vim.opt[opt]:get())
    end
end

Hydra({
    name = "Options",
    hint = [[
  ^ ^        Options
  ^
  _v_ %{ve} virtual edit
  _i_ %{list} invisible characters  ^
  _S_ %{spell} spell
  _w_ %{wrap} wrap
  _c_ %{cul} cursor line
  _n_ %{nu} number
  _r_ %{rnu} relative number
  _s_ %{so} scrolloff
  _f_ %{fc} foldcolumn
  _b_ %{bg}
  ^
       ^^^^                _<Esc>_
]],
    config = {
        color = "amaranth",
        invoke_on_body = true,
        hint = {
            position = "middle",
            float_opts = {
                border = "rounded",
            },
            funcs = {
                so = get_opt("scrolloff", "[%d]"),
                fc = get_opt("foldcolumn", "[%s]"),
                bg = get_opt("background", "[%.1s] background"),
            },
        },
    },
    mode = { "n", "x" },
    body = "<leader>t",
    heads = {
        { "n", boolean_switch("number"), { desc = "number" } },
        { "r", boolean_switch("relativenumber"), { desc = "relativenumber" } },
        { "i", boolean_switch("list"), { desc = "show invisible" } },
        { "w", boolean_switch("wrap"), { desc = "wrap" } },
        { "c", boolean_switch("cursorline"), { desc = "cursor line" } },
        { "S", boolean_switch("spell"), { desc = "spell" } },
        { "f", fold_column, { desc = "foldcolumn" }, },
        { "v", virtual_edit, { desc = "virtualedit" } },
        { "s", scrolloff_toggle, { desc = "scrolloff" }, },
        { "b", background, { desc = "background" }, },
        { "<Esc>", nil, { exit = true } },
    },
})
