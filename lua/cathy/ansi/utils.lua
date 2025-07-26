local M = {}

local Hl_Opts = {}
setmetatable(Hl_Opts, {
    __index = require("cathy.ansi.codes")
})

function Hl_Opts:apply_codes(codes)
    for _, code in ipairs(codes) do
        self[code](self)
    end
end

function Hl_Opts.new(tbl)
    return setmetatable(tbl or {}, {
        __index = Hl_Opts,
        __sub = Hl_Opts.__sub
    })
end

function Hl_Opts:set(values)
    for k in pairs(self) do
        self[k] = nil
    end

    for k, v in pairs(values) do
        self[k] = v
    end
end

local function get_hl_name(opts)
    local name = "ANSICODES__"
    if opts.fg then
        name = name .. "FG" .. string.sub(opts.fg, 2, -1)
    end
    if opts.bg then
        name = name .. "BG" .. string.sub(opts.bg, 2, -1)
    end

    for key, value in pairs(opts) do
        if key ~= "fg" and key ~= "bg" then
            if value then
                name = name .. string.upper(key)
            end
        end
    end
    return name
end

local hl_ns = vim.api.nvim_create_namespace("ANSICODE_HL")
local Range = {}
function Range:apply(bufnr, linenr)
    vim.validate("bufnr", bufnr, "number")
    vim.validate("linenr", linenr, "number")
    local hl_name = get_hl_name(self.hl_opts)
    if vim.fn.hlexists(hl_name) == 0 then
        vim.api.nvim_set_hl(0, hl_name, self.hl_opts)
    end
    vim.hl.range(bufnr, hl_ns, hl_name, { linenr, self.start }, { linenr, self.finish })
end

local function apply_ranges(self, bufnr, linenr)
    for _, range in ipairs(self) do
        range:apply(bufnr, linenr)
    end
end

function M.parse_codes(ansi_codes)
    local ranges = {}
    local previous_position = 0
    local previous_opts = Hl_Opts.new()
    local hl_opts = Hl_Opts.new()

    for _, codes in ipairs(ansi_codes) do
        hl_opts:set(previous_opts)
        hl_opts:apply_codes(codes.values)

        if not vim.deep_equal(previous_opts, hl_opts) and next(previous_opts) ~= nil then
            table.insert(ranges, setmetatable({
                start = previous_position - 1,
                finish = codes.pos - 1,
                hl_opts = setmetatable(vim.deepcopy(previous_opts), nil),
            }, { __index = Range }))
        end

        previous_position = codes.pos
        hl_opts, previous_opts = previous_opts, hl_opts
    end

    return setmetatable(ranges, { __index = { apply = apply_ranges }})
end

return M
