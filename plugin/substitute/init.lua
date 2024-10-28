CathySubstitute = {}

local input = function(opts)
    opts.cancelreturn = nil
    local ok, replace = pcall(vim.fn.input, opts)
    if not ok then return end
    return replace
end

local opts = {
    silent = true,
    expr = true
}

local cache = {
    query = "",
    replace = "",
    use_abolish = false,
}

CathySubstitute.formats = {
    normal = vim.keycode":<c-u>'[,']s///g<left><left>",
    normal_abolish = vim.keycode"gp<esc>:'<,'>S///g<left><left>",
    visual = ":s/%s/%s/gec<cr>",
    visual_abolish = ":S/%s/%s/gec<cr>",
}

local function get_placeholder(visual)
    if visual then
        return cache.use_abolish and CathySubstitute.formats.visual_abolish or CathySubstitute.formats.visual
    else
        return cache.use_abolish and CathySubstitute.formats.normal_abolish or CathySubstitute.formats.normal
    end
end

---@return string
local function query_prompt()
    if cache.query == "" then
        return "Query replace in region: "
    else
        return "Query replace in region (default "..cache.query.." -> "..cache.replace.."): "
    end
end

local function replace_prompt()
    if cache.replace == "" then
        return (cache.use_abolish and "[Using abolish] " or "") .. "Query replace "..cache.query.." with: "
    else
        return (cache.use_abolish and "[Using abolish] " or "") .. "Query replacing "..cache.query.." with "..cache.replace..": "
    end
end

local function do_query()
    local buf = vim.api.nvim_get_current_buf()
    vim.keymap.set("c", "<c-g>", function()
        cache.use_abolish = not cache.use_abolish
    end, { buffer = buf })

    local query = input({
        prompt = query_prompt(),
    })

    vim.keymap.del("c", "<c-g>", { buffer = buf })

    if not query then
        return false
    end
    cache.query = query ~= "" and query or cache.query
    return true
end

local function do_replace()
    local replace = input({
        prompt = replace_prompt(),
    })
    if not replace then
        return false
    end
    cache.replace = replace ~= "" and replace or cache.replace
    return true
end

---@return string?
local function visual_replace()
    cache.use_abolish = true
    if not do_query() then
        return "<esc>"
    end
    if not do_replace() then
        return "<esc>"
    end
    local str = string.format(get_placeholder(true), cache.query, cache.replace)
    cache.use_abolish = false
    return str
end

function CathySubstitute.replace()
    vim.api.nvim_feedkeys(get_placeholder(false), "m", false)
    vim.go.operatorfunc = "v:lua.CathySubstitute.replace"
end

local function meow(linewise, use_abolish)
    cache.use_abolish = use_abolish
    vim.go.operatorfunc = "v:lua.CathySubstitute.replace"
    if linewise then
        return "g@_"
    else
        return "g@"
    end
end

vim.keymap.set("n", "gs", function()
    return meow(false, false)
end, opts)

vim.keymap.set("n", "gss", function()
    return meow(true, false)
end, opts)

-- vim.keymap.set("n", "gS", function()
--     return meow(false, true)
-- end, opts)
--
-- vim.keymap.set("n", "gSS", function()
--     return meow(true, true)
-- end, opts)

vim.keymap.set("x", "gs", function()
    return visual_replace()
end, opts)
