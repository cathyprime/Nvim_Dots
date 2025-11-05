lua << EOF
local base = vim.api.nvim_get_hl(0, {
    name = "DiagnosticInfo"
})
base.underline = true
vim.api.nvim_set_hl(0, "CompileCmd", base)
EOF
syntax match CompileCmd /^\[CMD\]\s*::\s*\zs.*/

hi! link CompileModeErr DiffDelete
syntax match CompileModeErr /code\s*\zs\d\+/
syntax match CompileModeErr /^Compilation\s*\zs.*\ze\swith code/
syntax match CompileModeErr /^Compilation\s\+\zs[[:alpha:]() ]\+\ze\sat.\+duration/

hi! link CompileModeOk DiffAdd
syntax match CompileModeOk /^Compilation\s*\zs\<finished\>\ze/

syntax match DiagnosticWarn /\cwarn:/
syntax match DiagnosticWarn /\cwarning:/

syntax match DiagnosticInfo /\cnote:/
syntax match DiagnosticInfo /\cinfo:/

syntax match DiagnosticError /\cerror:/

lua << EOF
local hl = vim.api.nvim_get_hl(0, {
    name = "DiagnosticError"
})
hl.underline = true
vim.api.nvim_set_hl(0, "CompileModeFile", hl)
EOF

syntax match CompileModeFile /^[A-Za-z0-9._\/-]\+:/
