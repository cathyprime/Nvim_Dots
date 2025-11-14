local banned_fts = setmetatable({
    man = true,
    [""] = true,
    help = true,
}, { __index = function () return false end })

local allowed_uris = setmetatable({
    term = true,
    oil = true,
}, { __index = function () return false end })

local lpeg = vim.lpeg
local alpha = lpeg.R("AZ", "az")
local digit = lpeg.R("09")
local scheme_char = alpha + digit + lpeg.S("+-.")
local scheme = scheme_char^1
local rest = lpeg.P(1)^0
local uri_pattern = lpeg.C(scheme) * lpeg.P("://") * rest * -1
local prefix = scheme * lpeg.P("://")

local function should_switch(bufnr)
    local filetype = vim.bo[bufnr].filetype
    local name = vim.fn.bufname(bufnr)

    if banned_fts[filetype] then
        return true
    end

    local uri = uri_pattern:match(name) == nil
    return not allowed_uris[uri]
end

local function strip_uri(file)
    local pos = prefix:match(file)
    if not pos then
        return file
    end
    return file:sub(pos)
end

local uri_mod = {
    term = function (file)
        return vim.fn.fnamemodify(file:gsub("term://", ""):gsub("//.*", ""), ":p")
    end,
    oil = strip_uri
}

local function preprocess(file)
    local uri = uri_pattern:match(file)
    if not uri then
        return file
    end
    if not allowed_uris[uri] then
        return vim.uv.cwd()
    end

    return uri_mod[uri](file), uri == "oil"
end

vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = vim.api.nvim_create_augroup("Magda_Rooter", { clear = true }),
    pattern = "*",
    callback = function (env)
        if not should_switch(env.buf) then
            return
        end

        local pp = preprocess(env.file)
        if pp == "" then
            return
        end

        if vim.fn.isdirectory(pp) == 0 then
            pp = vim.fs.dirname(pp)
        end
        require("cathy.projectile").switch_cwd(pp)
    end
})

vim.api.nvim_create_user_command("Scopes", require("cathy.projectile").edit_scopes, { nargs = 0 })
