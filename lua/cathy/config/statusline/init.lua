local diff_signs = {
    add = "+",
    change = "~",
    delete = "-",
}

local k = vim.keycode
local CTRL_V = k"<c-v>"
local CTRL_S = k"<c-s>"

local five_hls = {
    ["n"]           = "StatuslineNormal",
    ["no"]          = "StatuslineNormal",
    ["nov"]         = "StatuslineNormal",
    ["noV"]         = "StatuslineNormal",
    ["noCTRL"]      = "StatuslineNormal",
    ["CTRL"]        = "StatuslineNormal",
    ["niI"]         = "StatuslineNormal",
    ["niR"]         = "StatuslineNormal",
    ["niV"]         = "StatuslineNormal",
    ["nt"]          = "StatuslineNormal",
    ["ntT"]         = "StatuslineNormal",
    ["v"]           = "StatuslineVisual",
    ["vs"]          = "StatuslineVisual",
    ["V"]           = "StatuslineVisual",
    ["Vs"]          = "StatuslineVisual",
    [CTRL_V]        = "StatuslineVisual",
    [CTRL_V .. "s"] = "StatuslineVisual",
    ["s"]           = "StatuslineVisual",
    ["S"]           = "StatuslineVisual",
    [CTRL_S]        = "StatuslineVisual",
    ["i"]           = "StatuslineInsert",
    ["ic"]          = "StatuslineInsert",
    ["ix"]          = "StatuslineInsert",
    ["R"]           = "StatuslineReplace",
    ["Rc"]          = "StatuslineReplace",
    ["Rx"]          = "StatuslineReplace",
    ["Rv"]          = "StatuslineReplace",
    ["Rvc"]         = "StatuslineReplace",
    ["Rvx"]         = "StatuslineReplace",
    ["c"]           = "StatuslineCommand",
    ["cr"]          = "StatuslineCommand",
    ["cv"]          = "StatuslineCommand",
    ["cvr"]         = "StatuslineCommand",
    ["r"]           = "StatuslineNormal",
    ["rm"]          = "StatuslineNormal",
    ["r?"]          = "StatuslineNormal",
    ["!"]           = "StatuslineNormal",
    ["t"]           = "StatuslineNormal",
}

local background_five_hls = {
    ["n"]           = "StatuslineBNormal",
    ["no"]          = "StatuslineBNormal",
    ["nov"]         = "StatuslineBNormal",
    ["noV"]         = "StatuslineBNormal",
    ["noCTRL"]      = "StatuslineBNormal",
    ["CTRL"]        = "StatuslineBNormal",
    ["niI"]         = "StatuslineBNormal",
    ["niR"]         = "StatuslineBNormal",
    ["niV"]         = "StatuslineBNormal",
    ["nt"]          = "StatuslineBNormal",
    ["ntT"]         = "StatuslineBNormal",
    ["v"]           = "StatuslineBVisual",
    ["vs"]          = "StatuslineBVisual",
    ["V"]           = "StatuslineBVisual",
    ["Vs"]          = "StatuslineBVisual",
    [CTRL_V]        = "StatuslineBVisual",
    [CTRL_V .. "s"] = "StatuslineBVisual",
    ["s"]           = "StatuslineBVisual",
    ["S"]           = "StatuslineBVisual",
    [CTRL_S]        = "StatuslineBVisual",
    ["i"]           = "StatuslineBInsert",
    ["ic"]          = "StatuslineBInsert",
    ["ix"]          = "StatuslineBInsert",
    ["R"]           = "StatuslineBReplace",
    ["Rc"]          = "StatuslineBReplace",
    ["Rx"]          = "StatuslineBReplace",
    ["Rv"]          = "StatuslineBReplace",
    ["Rvc"]         = "StatuslineBReplace",
    ["Rvx"]         = "StatuslineBReplace",
    ["c"]           = "StatuslineBCommand",
    ["cr"]          = "StatuslineBCommand",
    ["cv"]          = "StatuslineBCommand",
    ["cvr"]         = "StatuslineBCommand",
    ["r"]           = "StatuslineBNormal",
    ["rm"]          = "StatuslineBNormal",
    ["r?"]          = "StatuslineBNormal",
    ["!"]           = "StatuslineBNormal",
    ["t"]           = "StatuslineBNormal",
}

local function five_hl()
    return five_hls[vim.fn.mode()]
end

local function background_five_hl()
    return background_five_hls[vim.fn.mode()]
end

local function get_diff(which)
    if not vim.b.minidiff_summary then
        return ""
    end
    if vim.b.minidiff_summary[which] == 0 or vim.b.minidiff_summary[which] == nil then
        return ""
    end
    return diff_signs[which] .. vim.b.minidiff_summary[which]
end

local function format_element(hl, str)
    if str == "" then
        return ""
    end
    return string.format("%%#%s#%s", hl, str)
end

local function diff_component(args)
    if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
    end

    local space_added = false
    local add = get_diff("add")
    local change = get_diff("change")
    local delete = get_diff("delete")

    if not space_added and add ~= "" then
        add = " " .. add
        space_added = true
    end

    if not space_added and change ~= "" then
        change =  " " .. change
        space_added = true
    end

    if not space_added and delete ~= "" then
        delete = " " .. delete
        space_added = true
    end

    local ret_tbl = {
        format_element("StatusDiffAdded", add),
        format_element("StatusDiffChanged", change),
        format_element("StatusDiffDeleted", delete),
    }

    return vim.iter(ret_tbl):filter(function(elem)
        return elem ~= ""
    end):fold("", function(acc, elem)
        if acc == "" then
            return elem
        end
        return acc .. " " .. elem
    end)
end

local modes = {
    ["n"] =    { long = "NOR", short = "N",   hl = "MiniStatuslineModeNormal"      },
    ["v"] =    { long = "VIS", short = "V",   hl = "MiniStatuslineModeVisual"      },
    ["V"] =    { long = "VLN", short = "V-L", hl = "MiniStatuslineModeVisualLine"  },
    [CTRL_V] = { long = "VBL", short = "V-B", hl = "MiniStatuslineModeVisualBlock" },
    ["s"] =    { long = "SEL", short = "S",   hl = "MiniStatuslineModeSelect"      },
    ["S"] =    { long = "SLN", short = "S-L", hl = "MiniStatuslineModeSelect"      },
    [CTRL_S] = { long = "SBL", short = "S-B", hl = "MiniStatuslineModeSelect"      },
    ["i"] =    { long = "INS", short = "I",   hl = "MiniStatuslineModeInsert"      },
    ["R"] =    { long = "RPL", short = "R",   hl = "MiniStatuslineModeReplace"     },
    ["c"] =    { long = "CMD", short = "C",   hl = "MiniStatuslineModeCommand"     },
    ["r"] =    { long = "PMT", short = "P",   hl = "MiniStatuslineModeOther"       },
    ["!"] =    { long = "SHL", short = "Sh",  hl = "MiniStatuslineModeOther"       },
    ["t"] =    { long = "TRM", short = "T",   hl = "MiniStatuslineModeTerminal"    },
    ["dbg"] =  { long = "DBG", short = "D",   hl = "MiniStatuslineModeDebug"       },
    -- ["n"]    = { long = "[ Normal ]", short = "NOR", hl = "MiniStatuslineModeNormal"      },
    -- ["v"]    = { long = "[ Visual ]", short = "VIS", hl = "MiniStatuslineModeVisual"      },
    -- ["V"]    = { long = "[ VisLin ]", short = "VLN", hl = "MiniStatuslineModeVisualLine"  },
    -- [CTRL_V] = { long = "[ VisBlk ]", short = "VBL", hl = "MiniStatuslineModeVisualBlock" },
    -- ["s"]    = { long = "--Select--", short = "SEL", hl = "MiniStatuslineModeSelect"      },
    -- ["S"]    = { long = "--SelLin--", short = "SLN", hl = "MiniStatuslineModeSelect"      },
    -- [CTRL_S] = { long = "--SelBlk--", short = "SBL", hl = "MiniStatuslineModeSelect"      },
    -- ["i"]    = { long = "--Insert--", short = "INS", hl = "MiniStatuslineModeInsert"      },
    -- ["R"]    = { long = "--Replce--", short = "RPL", hl = "MiniStatuslineModeReplace"     },
    -- ["c"]    = { long = "--Cmmand--", short = "CMD", hl = "MiniStatuslineModeCommand"     },
    -- ["r"]    = { long = "--Prompt--", short = "PMT", hl = "MiniStatuslineModeOther"       },
    -- ["!"]    = { long = "--Shell --", short = "SHL", hl = "MiniStatuslineModeOther"       },
    -- ["t"]    = { long = "--Termnl--", short = "TRM", hl = "MiniStatuslineModeTerminal"    },
}

local function mode_component(args)
    local mode_info = modes[vim.fn.mode()]
    if vim.g.debug_mode then
        mode_info = modes["dbg"]
    end
    local mode = mode_info.long
    return mode, mode_info.hl
end

local function cursor_pos_component(args)
    if MiniStatusline.is_truncated(args.trunc_width) then
        return "%l:%c"
    end
    return "(%l:%c)"
end

local function cursor_pos_component_min(_)
    return "%l,%c"
end

local function window_component(args)
    if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
    end
    return string.format("[%s:%s]", vim.api.nvim_win_get_number(0), vim.api.nvim_get_current_buf())
end

local function get_hl()
    if vim.fn.reg_recording() ~= "" then
        return "statuslineRegisterRecording"
    else
        return background_five_hls[vim.fn.mode()]
    end
end


local function recording_component(args)
    local recording = vim.fn.reg_recording()
    if recording ~= "" then
        if not MiniStatusline.is_truncated(args.trunc_width) then
            recording = string.format("   -> %s", recording)
        end
    end
    local register = vim.v.register
    if register == "%" then
        register = "%%"
    end
    return string.format("%s%s", register, recording)
end

local function filename_component(args)
    if MiniStatusline.is_truncated(args.trunc_width) then
        return "%t %m%r"
    end
    if vim.bo.buftype == "terminal" then
        return "%t"
    end

    -- return vim.fn.expand('%:~:.') .. " %m%r"
    return "%F %m%r"
end

local function last_button_component(args)
    if MiniStatusline.is_truncated(args.trunc_width) then
        return ""
    end
    if vim.fn.mode() == "t" then
        return ""
    else
        return "%S"
    end
end

local diagnostic_is_disabled = function()
    return not vim.diagnostic.is_enabled({ bufnr = 0 })
end

local function filetype_component()
    if vim.bo.filetype == "" then
        return "[no ft]"
    end
    return "%y"
end

local diagnostic_levels = {
    { name = "INFO",  hl = "StatusDiagnosticSignInfo"  },
    { name = "WARN",  hl = "StatusDiagnosticSignWarn"  },
    { name = "ERROR", hl = "StatusDiagnosticSignError" },
}

local function diagnostics_component(args)
    if MiniStatusline.is_truncated(args.trunc_width) or diagnostic_is_disabled() then return "" end

    local count = vim.diagnostic.count()
    local severity, t = vim.diagnostic.severity, {}
    for _, level in ipairs(diagnostic_levels) do
        local n = count[severity[level.name]] or 0
        local item = format_element(level.hl, n)
        table.insert(t, item)
    end
    if #t == 0 then
        return ""
    end

    return string.format("%%#MiniStatuslineBrackets#[%s%%#MiniStatuslineBrackets#]", table.concat(t, " "))
end

local dap_names = {
    ["dapui_breakpoints"] = "DAP Breakpoints",
    ["dapui_watches"]     = "DAP Watches",
    ["dapui_console"]     = "DAP Console",
    ["dapui_scopes"]      = "DAP Scopes",
    ["dapui_stacks"]      = "DAP Stacks",
    ["dap-repl"]          = "DAP Repl",
}

local function Statusline_normal(active)
    if active then
        return "StatuslineNormal"
    else
        return "StatuslineNormalInactive"
    end
end

local function dap_component(active)
    local name = string.format("%s", dap_names[vim.bo.filetype])
    return MiniStatusline.combine_groups({
        { hl = Statusline_normal(active), strings = { name } },
        { hl = "MiniStatuslineDevinfoB", strings = { "%=" } }
    })
end

local function oil()
    local ok, oil = pcall(require, "oil")
    if ok then
        return vim.fn.fnamemodify(oil.get_current_dir(), ":~")
    else
        return ""
    end
end

local filetypes = {
    ["dapui_breakpoints"] = dap_component,
    ["dapui_watches"]     = dap_component,
    ["dapui_console"]     = dap_component,
    ["dapui_scopes"]      = dap_component,
    ["dapui_stacks"]      = dap_component,
    ["dap-repl"]          = dap_component,
    ["oil"] = function(active)
        return MiniStatusline.combine_groups({
            { hl = Statusline_normal(active), strings = { oil() } },
            { hl = "MiniStatuslineDevinfoB", strings = { "%=" } },
        })
    end,
    ["man"] = function(active)
        local name = vim.fn.bufname():gsub("man://", "")
        return MiniStatusline.combine_groups({
            { hl = Statusline_normal(active), strings = { "MAN" } },
            { hl = "MiniStatuslineDevinfo", strings = { name } },
            { hl = "MiniStatuslineDevinfoB", strings = { "%=" } },
            { hl = "MiniStatuslineDevinfo", strings = { "%P" } },
            { hl = "StatuslineNormal", strings = { "%l:%c" } },
        })
    end,
    ["qf"] = function(active)
        return MiniStatusline.combine_groups({
            { hl = Statusline_normal(active), strings = { "%q" } },
            { hl = "MiniStatuslineDevinfoB", strings = { "" }},
            "%=",
            { hl = "StatuslineNormal",  strings = { "(%l:%c)" } }
        })
    end,
    ["undotree"] = function(active)
        return MiniStatusline.combine_groups({
            { hl = Statusline_normal(active), strings = { "Undotree" } },
            { hl = "MiniStatuslineDevinfoB", strings = { "" }},
            "%=",
        })
    end,
}

local function choose()
    local ft = vim.bo.filetype
    local ok = vim.iter(filetypes):any(function(filetype)
        return filetype == ft
    end)
    if ok then
        return ok, filetypes[ft]
    end
end

return {
    filetype_specific = choose,
    mode_highlightsB = background_five_hl,
    mode_highlights = five_hl,
    cursor_pos_min = cursor_pos_component_min,
    last_button = last_button_component,
    diagnostics = diagnostics_component,
    cursor_pos = cursor_pos_component,
    recording = recording_component,
    record_hl = get_hl,
    filename = filename_component,
    window = window_component,
    mode = mode_component,
    diff = diff_component,
    filetype = filetype_component,
}
