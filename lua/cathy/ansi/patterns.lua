local M = {}
local C = vim.lpeg.C

local esc_char  = vim.lpeg.P"\27"
local bracket   = vim.lpeg.P"["
local digit     = vim.lpeg.R"09"
local semicolon = vim.lpeg.P";"
local cmd       = vim.lpeg.R("AZ", "az")

local parse_values = (digit^1 / tonumber)^1 * (semicolon * (digit^1 / tonumber))^0
local ansi_code = esc_char * bracket * vim.lpeg.Ct(parse_values) * C(cmd)

M.ansi_parse = ansi_code / function (values, cmd)
    return {
        values = values,
        cmd = cmd
    }
end
local ansi_value = (digit + semicolon) ^ 1
local ansi_code  = esc_char * bracket * (ansi_value^0) * cmd
local not_ansi   = (1 - ansi_code) ^ 0

M.has_ansi = not_ansi * ansi_code * not_ansi
M.ansi_normal_split = not_ansi * vim.lpeg.Cp() * ansi_code
M.scanner = (not_ansi * ansi_code ^ -1) * vim.lpeg.Cp()

return M
