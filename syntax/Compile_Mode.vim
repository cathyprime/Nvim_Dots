lua << EOF
local base = vim.api.nvim_get_hl(0, {
    name = "DiagnosticInfo"
})
base.underline = true
vim.api.nvim_set_hl(0, "CompileCmd", base)
EOF
syntax match CompileCmd /^\[CMD\]\s*::\s*\zs.*/

hi! link CompileModeErr DiffDelete
syntax match CompileModeErr /code\s*\zs\d\+/ contained
syntax match CompileModeErr /^Compilation\s*\zs.*\ze\swith/ contained
syntax match CompileModeErr /^Compilation\s\+\zs[[:alpha:]() ]\+\ze\sat/ contained

hi! link CompileModeOk DiffAdd
syntax match CompileModeOk /^Compilation\s*\zs\<finished\>\ze/ contained
syntax match LastLine /^.*\%$/ contains=CompileModeOk,CompileModeErr

syntax match CompileModeFile /^[~A-Za-z0-9_\/-]\+\.[A-Za-z0-9]\+/

syntax case ignore
syntax keyword CompileModeOk ok
syntax keyword DiagnosticWarn warn warning
syntax keyword DiagnosticInfo note info usage test testing
syntax keyword DiagnosticError fatal error failed errors failure

lua << EOF
local hl = vim.api.nvim_get_hl(0, {
    name = "DiagnosticError"
})
hl.underline = true
vim.api.nvim_set_hl(0, "CompileModeFile", hl)
EOF
