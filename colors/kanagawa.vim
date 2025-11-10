hi clear

let g:colors_name = "kanagawa"

if (has('termguicolors') && &termguicolors) || has('gui_running')
    let g:terminal_ansi_colors = [
        \'#16161D', '#C34043', '#76946A', '#C0A36E',
        \'#7E9CD8', '#957FB8', '#6A9589', '#C8C093',
        \'#727169', '#E82424', '#98BB6C', '#E6C384',
        \'#7FB4CA', '#938AA9', '#7AA89F', '#DCD7BA' ]
    " Nvim uses g:terminal_color_{0-15} instead
    for i in range(g:terminal_ansi_colors->len())
        let g:terminal_color_{i} = g:terminal_ansi_colors[i]
    endfor
endif

function s:kanagawa_light()
    hi Normal guifg=#54546D guibg=#FBFAEE guisp=NONE blend=NONE gui=NONE
    hi Boolean guifg=#FF751F guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Character guifg=#6E915F guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi CmpCompletionBorder guifg=#81B4CA guibg=#F2EBBB guisp=NONE blend=NONE gui=NONE
    hi CmpCompletionSel guifg=NONE guibg=#E4D795 guisp=NONE blend=NONE gui=NONE
    hi CmpItemAbbr guifg=#54546D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi CmpItemAbbrDeprecated guifg=#C2708B guibg=NONE guisp=NONE blend=NONE gui=strikethrough
    hi CmpItemAbbrMatch guifg=#0054E6 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi CmpItemKindClass guifg=#274F42 guibg=#4FA187 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindColor guifg=#324667 guibg=#6985B5 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindConstant guifg=#D65200 guibg=#FFA166 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindConstructor guifg=#003899 guibg=#1F71FF guisp=NONE blend=NONE gui=standout
    hi CmpItemKindCopilot guifg=#48603E guibg=#8BAA7D guisp=NONE blend=NONE gui=standout
    hi CmpItemKindEnum guifg=#274F42 guibg=#4FA187 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindEnumMember guifg=#D65200 guibg=#FFA166 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindEvent guifg=#274F42 guibg=#4FA187 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindField guifg=#765641 guibg=#BC9A85 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindFile guifg=#355EB1 guibg=#99B1E1 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindFolder guifg=#355EB1 guibg=#99B1E1 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindFunction guifg=#003899 guibg=#1F71FF guisp=NONE blend=NONE gui=standout
    hi CmpItemKindInterface guifg=#274F42 guibg=#4FA187 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindKeyword guifg=#3B1381 guibg=#7333E1 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindMethod guifg=#003899 guibg=#1F71FF guisp=NONE blend=NONE gui=standout
    hi CmpItemKindModule guifg=#373748 guibg=#6F6F90 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindOperator guifg=#64573A guibg=#AE9C75 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindProperty guifg=#765641 guibg=#BC9A85 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindReference guifg=#324667 guibg=#6985B5 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindSnippet guifg=#324667 guibg=#6985B5 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindStruct guifg=#274F42 guibg=#4FA187 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindText guifg=#373748 guibg=#6F6F90 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindTypeParameter guifg=#274F42 guibg=#4FA187 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindUnit guifg=#BA2133 guibg=#EA8691 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindValue guifg=#48603E guibg=#8BAA7D guisp=NONE blend=NONE gui=standout
    hi CmpItemKindVariable guifg=#373748 guibg=#6F6F90 guisp=NONE blend=NONE gui=standout
    hi ColorColumn guifg=NONE guibg=#E6E3D0 guisp=NONE blend=NONE gui=NONE
    hi Comment guifg=#C2708B guibg=NONE guisp=NONE blend=NONE gui=italic
    hi Conceal guifg=#928AA8 guibg=NONE guisp=NONE blend=NONE gui=bold
    hi Constant guifg=#FF8B42 guibg=NONE guisp=NONE blend=NONE gui=bold
    hi CurSearch guifg=#DDD8BB guibg=#5E84C4 guisp=NONE blend=NONE gui=NONE
    hi Cursor guifg=#DDD8BB guibg=#C34143 guisp=NONE blend=NONE gui=NONE
    hi CursorLine guifg=NONE guibg=#F6F1D0 guisp=NONE blend=NONE gui=NONE
    hi CursorLineNr guifg=NONE guibg=#DCADBD guisp=NONE blend=NONE gui=bold
    hi DapUIBreakpointsCurrentLine guifg=#54546D guibg=NONE guisp=NONE blend=NONE gui=bold
    hi DapUIDecoration guifg=#CDCAB9 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DapUIModifiedValue guifg=#4C689A guibg=NONE guisp=NONE blend=NONE gui=bold
    hi DiagnosticError guifg=#E82626 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiagnosticHint guifg=#6A9589 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiagnosticInfo guifg=#658695 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiagnosticOk guifg=#98BC6C guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiagnosticUnderlineError guifg=NONE guibg=NONE guisp=#E82626 blend=NONE gui=undercurl
    hi DiagnosticUnderlineHint guifg=NONE guibg=NONE guisp=#6A9589 blend=NONE gui=undercurl
    hi DiagnosticUnderlineInfo guifg=NONE guibg=NONE guisp=#658695 blend=NONE gui=undercurl
    hi DiagnosticUnderlineOk guifg=NONE guibg=NONE guisp=#98BC6C blend=NONE gui=undercurl
    hi DiagnosticUnderlineWarn guifg=NONE guibg=NONE guisp=#FF9E3D blend=NONE gui=undercurl
    hi DiagnosticWarn guifg=#FF9E3D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiffAdd guifg=#76956A guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiffAddRev guifg=#76956A guibg=NONE guisp=NONE blend=NONE gui=reverse
    hi DiffChange guifg=#DCA460 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiffChangeRev guifg=#DCA460 guibg=NONE guisp=NONE blend=NONE gui=reverse
    hi DiffCurrent guifg=#DCA460 guibg=#F7F3DE guisp=NONE blend=NONE gui=NONE
    hi DiffDelete guifg=#C34143 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiffDeleteRev guifg=#C34143 guibg=NONE guisp=NONE blend=NONE gui=reverse
    hi DiffIncoming guifg=#76956A guibg=#F7F3DE guisp=NONE blend=NONE gui=NONE
    hi DiffText guifg=NONE guibg=#F2EBCA guisp=NONE blend=NONE gui=NONE
    hi Directory guifg=#7D9CD8 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi EndOfBuffer guifg=#C8C092 guibg=#FBFAEE guisp=NONE blend=NONE gui=NONE
    hi Error guifg=#E82626 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi ErrorMsg guifg=#E82626 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Exception guifg=#E82626 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi FloatBorder guifg=#CDCAB9 guibg=#FBFAEE guisp=NONE blend=NONE gui=NONE
    hi FloatTitle guifg=#928AA8 guibg=#FBFAEE guisp=NONE blend=NONE gui=bold
    hi FoldColumn guifg=#54546D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Folded guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Function guifg=#0054E6 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi HydraAmaranth guifg=#ff1757 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi HydraBlue guifg=#5EBCF6 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi HydraPink guifg=#ff55de guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi HydraRed guifg=#FF5733 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi HydraTeal guifg=#00a1a1 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Identifier guifg=#54546D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi IncSearch guifg=#223249 guibg=#FF9E3D guisp=NONE blend=NONE gui=NONE
    hi Keyword guifg=#581DBF guibg=NONE guisp=NONE blend=NONE gui=italic
    hi LineNr guifg=#54546D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi LspCodeLens guifg=#727169 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi LspReferenceText guifg=NONE guibg=#DEDAC8 guisp=NONE blend=NONE gui=NONE
    hi LspReferenceWrite guifg=NONE guibg=#DEDAC8 guisp=NONE blend=NONE gui=underline
    hi LspSignatureActiveParameter guifg=#FF9E3D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi MatchParen guifg=#FF9E3D guibg=NONE guisp=NONE blend=NONE gui=bold
    hi MiniDiffOverAdd guifg=NONE guibg=#ADC0A5 guisp=NONE blend=NONE gui=NONE
    hi MiniDiffOverChange guifg=NONE guibg=#EAC89F guisp=NONE blend=NONE gui=NONE
    hi MiniDiffOverContext guifg=NONE guibg=#E1E7EA guisp=NONE blend=NONE gui=NONE
    hi MiniDiffOverDelete guifg=NONE guibg=#ADC0A5 guisp=NONE blend=NONE gui=NONE
    hi MiniHipatternsFixme guifg=#FBFAEE guibg=#E82626 guisp=NONE blend=NONE gui=bold
    hi MiniHipatternsHack guifg=#FBFAEE guibg=#FF9E3D guisp=NONE blend=NONE gui=bold
    hi MiniHipatternsNote guifg=#FBFAEE guibg=#658695 guisp=NONE blend=NONE gui=bold
    hi MiniHipatternsTodo guifg=#FBFAEE guibg=#6A9589 guisp=NONE blend=NONE gui=bold
    hi MiniIndentscopePrefix guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=nocombine
    hi MiniNotifyBorder guifg=#CDCAB9 guibg=#FBFAEE guisp=NONE blend=NONE gui=NONE
    hi MiniNotifyNormal guifg=#1F1F28 guibg=#FBFAEE guisp=NONE blend=NONE gui=NONE
    hi MiniNotifyTitle guifg=#928AA8 guibg=#FBFAEE guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineBrackets guifg=#948057 guibg=#D3E0E4 guisp=NONE blend=NONE gui=NONE
    hi MiniStatuslineDevinfo guifg=#16161D guibg=#98BC6C guisp=NONE blend=NONE gui=NONE
    hi MiniStatuslineDevinfoB guifg=#2A2A37 guibg=#F2ECBF guisp=NONE blend=NONE gui=NONE
    hi MiniStatuslineModeCommand guifg=#181820 guibg=#FFA166 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeDebug guifg=#C8C092 guibg=#E82626 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeInsert guifg=#181820 guibg=#7D9CD8 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeNormal guifg=#C8C092 guibg=#581DBF guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeOther guifg=#C8C092 guibg=#5E57A2 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeReplace guifg=#181820 guibg=#E82626 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeSelect guifg=#4C689A guibg=#7D9CD8 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeTerminal guifg=#E6C484 guibg=#615337 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeVisual guifg=#181820 guibg=#76956A guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeVisualBlock guifg=#7D9CD8 guibg=#EEEBDB guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeVisualLine guifg=#F5F4EB guibg=#CC6D00 guisp=NONE blend=NONE gui=bold
    hi MiniTrailspace guifg=#FF5C61 guibg=#FF5C61 guisp=NONE blend=NONE gui=NONE
    hi ModeMsg guifg=#FF9E3D guibg=NONE guisp=NONE blend=NONE gui=bold
    hi MoreMsg guifg=#658695 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi MsgArea guifg=#2A2A37 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi MsgSeparator guifg=NONE guibg=#E4D795 guisp=NONE blend=NONE gui=NONE
    hi MultiCursorCursor guifg=#FBFAEE guibg=#54546D guisp=NONE blend=NONE gui=NONE
    hi NeogitDiffAdd guifg=#76956A guibg=#E4EAE1 guisp=NONE blend=NONE gui=NONE
    hi NeogitDiffAddHighlight guifg=#76956A guibg=#E4EAE1 guisp=NONE blend=NONE gui=NONE
    hi NeogitDiffDelete guifg=#C34143 guibg=#F3D8D9 guisp=NONE blend=NONE gui=NONE
    hi NeogitDiffDeleteHighlight guifg=#C34143 guibg=#F3D8D9 guisp=NONE blend=NONE gui=NONE
    hi NeogitHunkHeaderHighlight guifg=#7459A1 guibg=NONE guisp=NONE blend=NONE gui=bold
    hi NeogitSubtleText guifg=#A5A59C guibg=NONE guisp=NONE blend=NONE gui=italic
    hi NonText guifg=#54546D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi NormalFloat guifg=#1F1F28 guibg=#FBFAEE guisp=NONE blend=NONE gui=NONE
    hi Number guifg=#E46776 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Operator guifg=#948057 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Pmenu guifg=#54546D guibg=#F2EBBB guisp=NONE blend=NONE gui=NONE
    hi PmenuExtra guifg=#928AA8 guibg=#F3EEC3 guisp=NONE blend=NONE gui=NONE
    hi PmenuExtraSel guifg=#928AA8 guibg=#E7E0B6 guisp=NONE blend=NONE gui=NONE
    hi PmenuKind guifg=#2A2A37 guibg=#F3EEC3 guisp=NONE blend=NONE gui=NONE
    hi PmenuKindSel guifg=#C8C092 guibg=#E7E0B6 guisp=NONE blend=NONE gui=NONE
    hi PmenuSbar guifg=NONE guibg=#E4DCAF guisp=NONE blend=NONE gui=NONE
    hi PmenuSel guifg=NONE guibg=#E4D795 guisp=NONE blend=NONE gui=NONE
    hi PmenuThumb guifg=NONE guibg=#E4D795 guisp=NONE blend=NONE gui=NONE
    hi PortalBlue guifg=#0078ff guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi PortalOrange guifg=#fd6600 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi PreProc guifg=#FF5C61 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Property guifg=#AC8268 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi QuickFixLine guifg=NONE guibg=#E8DCA1 guisp=NONE blend=NONE gui=NONE
    hi Search guifg=#DDD8BB guibg=#81B4CA guisp=NONE blend=NONE gui=NONE
    hi SignColumn guifg=#928AA8 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi SnacksNotifierMinimal guifg=#54546D guibg=#E9EFF1 guisp=NONE blend=NONE gui=NONE
    hi Special guifg=#4C689A guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi SpecialKey guifg=#928AA8 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi SpellBad guifg=NONE guibg=NONE guisp=#E82626 blend=NONE gui=undercurl
    hi SpellCap guifg=NONE guibg=NONE guisp=#FF9E3D blend=NONE gui=undercurl
    hi SpellLocal guifg=NONE guibg=NONE guisp=#FF9E3D blend=NONE gui=undercurl
    hi SpellRare guifg=NONE guibg=NONE guisp=#FF9E3D blend=NONE gui=undercurl
    hi StatusDiagnosticSignError guifg=#E82626 guibg=#D3E0E4 guisp=NONE blend=NONE gui=NONE
    hi StatusDiagnosticSignHint guifg=#6A9589 guibg=#D3E0E4 guisp=NONE blend=NONE gui=NONE
    hi StatusDiagnosticSignInfo guifg=#658695 guibg=#D3E0E4 guisp=NONE blend=NONE gui=NONE
    hi StatusDiagnosticSignWarn guifg=#FF9E3D guibg=#D3E0E4 guisp=NONE blend=NONE gui=NONE
    hi StatusDiffAdded guifg=#76956A guibg=#F2ECBF guisp=NONE blend=NONE gui=NONE
    hi StatusDiffChanged guifg=#DCA460 guibg=#F2ECBF guisp=NONE blend=NONE gui=NONE
    hi StatusDiffDeleted guifg=#C34143 guibg=#F2ECBF guisp=NONE blend=NONE gui=NONE
    hi StatusLine guifg=#2A2A37 guibg=#F2ECBF guisp=NONE blend=NONE gui=NONE
    hi StatusLineNC guifg=NONE guibg=#F2ECBF guisp=NONE blend=NONE gui=NONE
    hi StatuslineBCommand guifg=#948057 guibg=#D3E0E4 guisp=NONE blend=NONE gui=bold
    hi StatuslineBInsert guifg=#7AA14A guibg=#D3E0E4 guisp=NONE blend=NONE gui=bold
    hi StatuslineBNormal guifg=#5B7786 guibg=#D3E0E4 guisp=NONE blend=NONE gui=bold
    hi StatuslineBNormalInactive guifg=#5B7786 guibg=#D3E0E4 guisp=NONE blend=NONE gui=bold
    hi StatuslineBReplace guifg=#CC6D00 guibg=#D3E0E4 guisp=NONE blend=NONE gui=bold
    hi StatuslineBVisual guifg=#5E57A2 guibg=#D3E0E4 guisp=NONE blend=NONE gui=bold
    hi StatuslineCommand guifg=#1F1F28 guibg=#BFA36E guisp=NONE blend=NONE gui=NONE
    hi StatuslineInsert guifg=#1F1F28 guibg=#98BC6C guisp=NONE blend=NONE gui=NONE
    hi StatuslineNormal guifg=#16161D guibg=#7D9CD8 guisp=NONE blend=NONE gui=NONE
    hi StatuslineNormalInactive guifg=#C8C092 guibg=#7D9CD8 guisp=NONE blend=NONE gui=NONE
    hi StatuslineReplace guifg=#1F1F28 guibg=#FFA166 guisp=NONE blend=NONE gui=NONE
    hi StatuslineVisual guifg=#1F1F28 guibg=#957FB8 guisp=NONE blend=NONE gui=NONE
    hi String guifg=#6E915F guibg=NONE guisp=NONE blend=NONE gui=italic
    hi Substitute guifg=#DDD8BB guibg=#C34143 guisp=NONE blend=NONE gui=NONE
    hi TabLine guifg=#928AA8 guibg=#F2ECBF guisp=NONE blend=NONE gui=NONE
    hi TabLineFill guifg=NONE guibg=#F2EBBB guisp=NONE blend=NONE gui=NONE
    hi TabLineSel guifg=#2A2A37 guibg=#E4D795 guisp=NONE blend=NONE gui=NONE
    hi TelescopeBorder guifg=#D5D2C1 guibg=#FBFAEE guisp=NONE blend=NONE gui=NONE
    hi TelescopePreviewBorder guifg=#EEEBDB guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi TelescopePromptBorder guifg=#D5D2C1 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi TelescopeResultsBorder guifg=#E6E3D0 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi TelescopeResultsNormal guifg=#1F1F28 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi TelescopeSelectionCaret guifg=#FF8000 guibg=NONE guisp=NONE blend=NONE gui=bold
    hi TermCursor guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=reverse
    hi TermCursorNC guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Title guifg=#7D9CD8 guibg=NONE guisp=NONE blend=NONE gui=bold
    hi Todo guifg=#223249 guibg=#A4D4D5 guisp=NONE blend=NONE gui=bold
    hi TreesitterContextLineNumber guifg=#928AA8 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Type guifg=#397462 guibg=NONE guisp=NONE blend=NONE gui=nocombine
    hi Underlined guifg=#7D9CD8 guibg=NONE guisp=NONE blend=NONE gui=underline
    hi WinSeparator guifg=#F2ECBF guibg=#F2ECBF guisp=NONE blend=NONE gui=NONE
    hi Visual guifg=NONE guibg=#A4D4D5 guisp=NONE blend=NONE gui=NONE
    hi WarningMsg guifg=#FF9E3D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Whitespace guifg=#E8DCA1 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi WinBar guifg=#2A2A37 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi WinBarNC guifg=#2A2A37 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Yank guifg=#C8C092 guibg=#AA83EC guisp=NONE blend=NONE gui=NONE
    hi lCursor guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi statuslineRegister guifg=#16161D guibg=#7D9CD8 guisp=NONE blend=NONE gui=bold
    hi statuslineRegisterRecording guifg=#D8E4D9 guibg=#E82626 guisp=NONE blend=NONE gui=bold
    hi @comment.gitcommit guifg=#A5A59C guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @constant.builtin guifg=#FF8B42 guibg=NONE guisp=NONE blend=NONE gui=bold,italic
    hi @constructor guifg=#0054E6 guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @function.builtin guifg=#0054E6 guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @keyword.import guifg=#FF5C61 guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @keyword.nullptr guifg=#581DBF guibg=NONE guisp=NONE blend=NONE gui=italic,nocombine
    hi @keyword.return guifg=#FF383F guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @lsp.type.keyword guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi @lsp.type.variable guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi @markup.heading.gitcommit guifg=#7D9CD8 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi @markup.link.url.markdown_inline guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi @namespace guifg=#54546D guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @type.builtin guifg=#397462 guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @variable.builtin guifg=#581DBF guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @variable.builtin.vim guifg=#4C689A guibg=NONE guisp=NONE blend=NONE gui=italic
endfunction

function! s:kanagawa_dark()
    hi Normal guifg=#DDD8BB guibg=#181820 guisp=NONE blend=NONE gui=NONE
    hi Boolean guifg=#FFA166 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Character guifg=#98BC6C guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi CmpCompletionBorder guifg=#2D4F67 guibg=#2A2A37 guisp=NONE blend=NONE gui=NONE
    hi CmpCompletionSel guifg=NONE guibg=#353545 guisp=NONE blend=NONE gui=NONE
    hi CmpItemAbbr guifg=#DDD8BB guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi CmpItemAbbrDeprecated guifg=#B86C3D guibg=NONE guisp=NONE blend=NONE gui=strikethrough
    hi CmpItemAbbrMatch guifg=#7D9CD8 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi CmpItemKindClass guifg=#689C92 guibg=#3C5D56 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindColor guifg=#6CA8C1 guibg=#33657A guisp=NONE blend=NONE gui=standout
    hi CmpItemKindConstant guifg=#FF8B42 guibg=#B84600 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindConstructor guifg=#6287D0 guibg=#294989 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindCopilot guifg=#89B257 guibg=#4F6930 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindEnum guifg=#689C92 guibg=#3C5D56 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindEnumMember guifg=#FF8B42 guibg=#B84600 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindEvent guifg=#689C92 guibg=#3C5D56 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindField guifg=#E0B567 guibg=#9D7120 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindFile guifg=#6287D0 guibg=#294989 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindFolder guifg=#6287D0 guibg=#294989 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindFunction guifg=#6287D0 guibg=#294989 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindInterface guifg=#689C92 guibg=#3C5D56 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindKeyword guifg=#846BAE guibg=#4C3A69 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindMethod guifg=#6287D0 guibg=#294989 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindModule guifg=#CFC8A0 guibg=#8B8146 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindOperator guifg=#B69558 guibg=#6E5830 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindProperty guifg=#E0B567 guibg=#9D7120 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindReference guifg=#6CA8C1 guibg=#33657A guisp=NONE blend=NONE gui=standout
    hi CmpItemKindSnippet guifg=#6CA8C1 guibg=#33657A guisp=NONE blend=NONE gui=standout
    hi CmpItemKindStruct guifg=#689C92 guibg=#3C5D56 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindText guifg=#CFC8A0 guibg=#8B8146 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindTypeParameter guifg=#689C92 guibg=#3C5D56 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindUnit guifg=#C96484 guibg=#802D47 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindValue guifg=#89B257 guibg=#4F6930 guisp=NONE blend=NONE gui=standout
    hi CmpItemKindVariable guifg=#BCB37B guibg=#776E3C guisp=NONE blend=NONE gui=standout
    hi ColorColumn guifg=NONE guibg=#2A2A37 guisp=NONE blend=NONE gui=NONE
    hi Comment guifg=#B86C3D guibg=NONE guisp=NONE blend=NONE gui=italic
    hi Conceal guifg=#928AA8 guibg=NONE guisp=NONE blend=NONE gui=bold
    hi Constant guifg=#FFA166 guibg=NONE guisp=NONE blend=NONE gui=bold
    hi CurSearch guifg=#DDD8BB guibg=#2D4F67 guisp=NONE blend=NONE gui=NONE
    hi Cursor guifg=#DDD8BB guibg=#C34143 guisp=NONE blend=NONE gui=NONE
    hi CursorLine guifg=NONE guibg=#353545 guisp=NONE blend=NONE gui=NONE
    hi CursorLineNr guifg=NONE guibg=#7A3B3D guisp=NONE blend=NONE gui=bold
    hi DapUIBreakpointsCurrentLine guifg=#DDD8BB guibg=NONE guisp=NONE blend=NONE gui=bold
    hi DapUIDecoration guifg=#54546D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DapUIModifiedValue guifg=#81B4CA guibg=NONE guisp=NONE blend=NONE gui=bold
    hi DiagnosticError guifg=#E82626 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiagnosticHint guifg=#6A9589 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiagnosticInfo guifg=#658695 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiagnosticOk guifg=#98BC6C guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiagnosticUnderlineError guifg=NONE guibg=NONE guisp=#E82626 blend=NONE gui=undercurl
    hi DiagnosticUnderlineHint guifg=NONE guibg=NONE guisp=#6A9589 blend=NONE gui=undercurl
    hi DiagnosticUnderlineInfo guifg=NONE guibg=NONE guisp=#658695 blend=NONE gui=undercurl
    hi DiagnosticUnderlineOk guifg=NONE guibg=NONE guisp=#98BC6C blend=NONE gui=undercurl
    hi DiagnosticUnderlineWarn guifg=NONE guibg=NONE guisp=#FF9E3D blend=NONE gui=undercurl
    hi DiagnosticWarn guifg=#FF9E3D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiffAdd guifg=#76956A guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiffAddRev guifg=#76956A guibg=NONE guisp=NONE blend=NONE gui=reverse
    hi DiffChange guifg=#DCA460 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiffChangeRev guifg=#DCA460 guibg=NONE guisp=NONE blend=NONE gui=reverse
    hi DiffCurrent guifg=#DCA460 guibg=#2D2A25 guisp=NONE blend=NONE gui=NONE
    hi DiffDelete guifg=#C34143 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi DiffDeleteRev guifg=#C34143 guibg=NONE guisp=NONE blend=NONE gui=reverse
    hi DiffIncoming guifg=#76956A guibg=#2D2A25 guisp=NONE blend=NONE gui=NONE
    hi DiffText guifg=NONE guibg=#49443C guisp=NONE blend=NONE gui=NONE
    hi Directory guifg=#7D9CD8 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi EndOfBuffer guifg=#54546D guibg=#181820 guisp=NONE blend=NONE gui=NONE
    hi Error guifg=#E82626 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi ErrorMsg guifg=#E82626 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Exception guifg=#E46776 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi FloatBorder guifg=#54546D guibg=#16161D guisp=NONE blend=NONE gui=NONE
    hi FloatTitle guifg=#928AA8 guibg=#16161D guisp=NONE blend=NONE gui=bold
    hi FoldColumn guifg=#54546D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Folded guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Function guifg=#7D9CD8 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi HydraAmaranth guifg=#ff1757 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi HydraBlue guifg=#5EBCF6 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi HydraPink guifg=#ff55de guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi HydraRed guifg=#FF5733 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi HydraTeal guifg=#00a1a1 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Identifier guifg=#DDD8BB guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi IncSearch guifg=#223249 guibg=#FF9E3D guisp=NONE blend=NONE gui=NONE
    hi Keyword guifg=#957FB8 guibg=NONE guisp=NONE blend=NONE gui=italic
    hi LineNr guifg=#54546D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi LspCodeLens guifg=#727169 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi LspReferenceText guifg=NONE guibg=#49443C guisp=NONE blend=NONE gui=NONE
    hi LspReferenceWrite guifg=NONE guibg=#49443C guisp=NONE blend=NONE gui=underline
    hi LspSignatureActiveParameter guifg=#FF9E3D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi MatchParen guifg=#FF9E3D guibg=NONE guisp=NONE blend=NONE gui=bold
    hi MiniDiffOverAdd guifg=NONE guibg=#ADC0A5 guisp=NONE blend=NONE gui=NONE
    hi MiniDiffOverChange guifg=NONE guibg=#EAC89F guisp=NONE blend=NONE gui=NONE
    hi MiniDiffOverContext guifg=NONE guibg=#E1E7EA guisp=NONE blend=NONE gui=NONE
    hi MiniDiffOverDelete guifg=NONE guibg=#ADC0A5 guisp=NONE blend=NONE gui=NONE
    hi MiniHipatternsFixme guifg=#181820 guibg=#E82626 guisp=NONE blend=NONE gui=bold
    hi MiniHipatternsHack guifg=#181820 guibg=#FF9E3D guisp=NONE blend=NONE gui=bold
    hi MiniHipatternsNote guifg=#181820 guibg=#658695 guisp=NONE blend=NONE gui=bold
    hi MiniHipatternsTodo guifg=#181820 guibg=#6A9589 guisp=NONE blend=NONE gui=bold
    hi MiniIndentscopePrefix guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=nocombine
    hi MiniNotifyBorder guifg=#54546D guibg=#181820 guisp=NONE blend=NONE gui=NONE
    hi MiniNotifyNormal guifg=#C8C092 guibg=#181820 guisp=NONE blend=NONE gui=NONE
    hi MiniNotifyTitle guifg=#928AA8 guibg=#181820 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineBrackets guifg=#DCA460 guibg=#262636 guisp=NONE blend=NONE gui=NONE
    hi MiniStatuslineDevinfo guifg=#16161D guibg=#98BC6C guisp=NONE blend=NONE gui=NONE
    hi MiniStatuslineDevinfoB guifg=#DDD8BB guibg=#353545 guisp=NONE blend=NONE gui=NONE
    hi MiniStatuslineModeCommand guifg=#181820 guibg=#FFA166 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeDebug guifg=#C8C092 guibg=#E82626 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeInsert guifg=#181820 guibg=#7D9CD8 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeNormal guifg=#C8C092 guibg=#581DBF guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeOther guifg=#C8C092 guibg=#4C689A guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeReplace guifg=#181820 guibg=#E82626 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeSelect guifg=#A0B6CA guibg=#7D9CD8 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeTerminal guifg=#E6C484 guibg=#181820 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeVisual guifg=#181820 guibg=#76956A guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeVisualBlock guifg=#7D9CD8 guibg=#181820 guisp=NONE blend=NONE gui=bold
    hi MiniStatuslineModeVisualLine guifg=#C8C092 guibg=#CC6D00 guisp=NONE blend=NONE gui=bold
    hi MiniTrailspace guifg=#FF5C61 guibg=#FF5C61 guisp=NONE blend=NONE gui=NONE
    hi ModeMsg guifg=#FF9E3D guibg=NONE guisp=NONE blend=NONE gui=bold
    hi MoreMsg guifg=#658695 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi MsgArea guifg=#C8C092 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi MsgSeparator guifg=NONE guibg=#16161D guisp=NONE blend=NONE gui=NONE
    hi MultiCursorCursor guifg=#181820 guibg=#DDD8BB guisp=NONE blend=NONE gui=NONE
    hi NeogitDiffAdd guifg=#76956A guibg=#2F3C2A guisp=NONE blend=NONE gui=NONE
    hi NeogitDiffAddHighlight guifg=#76956A guibg=#2F3C2A guisp=NONE blend=NONE gui=NONE
    hi NeogitDiffDelete guifg=#C34143 guibg=#4E1819 guisp=NONE blend=NONE gui=NONE
    hi NeogitDiffDeleteHighlight guifg=#C34143 guibg=#4E1819 guisp=NONE blend=NONE gui=NONE
    hi NeogitHunkHeaderHighlight guifg=#9CABC9 guibg=NONE guisp=NONE blend=NONE gui=bold
    hi NeogitSubtleText guifg=#727169 guibg=NONE guisp=NONE blend=NONE gui=italic
    hi NonText guifg=#54546D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi NormalFloat guifg=#C8C092 guibg=#16161D guisp=NONE blend=NONE gui=NONE
    hi Number guifg=#D27F99 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Operator guifg=#BFA36E guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Pmenu guifg=#DDD8BB guibg=#2A2A37 guisp=NONE blend=NONE gui=NONE
    hi PmenuExtra guifg=#928AA8 guibg=#223249 guisp=NONE blend=NONE gui=NONE
    hi PmenuExtraSel guifg=#928AA8 guibg=#2D4F67 guisp=NONE blend=NONE gui=NONE
    hi PmenuKind guifg=#C8C092 guibg=#223249 guisp=NONE blend=NONE gui=NONE
    hi PmenuKindSel guifg=#C8C092 guibg=#2D4F67 guisp=NONE blend=NONE gui=NONE
    hi PmenuSbar guifg=NONE guibg=#1B1B23 guisp=NONE blend=NONE gui=NONE
    hi PmenuSel guifg=NONE guibg=#353545 guisp=NONE blend=NONE gui=NONE
    hi PmenuThumb guifg=NONE guibg=#353545 guisp=NONE blend=NONE gui=NONE
    hi PortalBlue guifg=#0078ff guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi PortalOrange guifg=#fd6600 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi PreProc guifg=#E46776 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Property guifg=#E6C484 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi QuickFixLine guifg=NONE guibg=#2A2A37 guisp=NONE blend=NONE gui=NONE
    hi Search guifg=#DDD8BB guibg=#2D4F67 guisp=NONE blend=NONE gui=NONE
    hi SignColumn guifg=#928AA8 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi SnacksNotifierMinimal guifg=#DDD8BB guibg=#474766 guisp=NONE blend=NONE gui=NONE
    hi Special guifg=#81B4CA guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi SpecialKey guifg=#928AA8 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi SpellBad guifg=NONE guibg=NONE guisp=#E82626 blend=NONE gui=undercurl
    hi SpellCap guifg=NONE guibg=NONE guisp=#FF9E3D blend=NONE gui=undercurl
    hi SpellLocal guifg=NONE guibg=NONE guisp=#FF9E3D blend=NONE gui=undercurl
    hi SpellRare guifg=NONE guibg=NONE guisp=#FF9E3D blend=NONE gui=undercurl
    hi StatusDiagnosticSignError guifg=#E82626 guibg=#262636 guisp=NONE blend=NONE gui=NONE
    hi StatusDiagnosticSignHint guifg=#6A9589 guibg=#262636 guisp=NONE blend=NONE gui=NONE
    hi StatusDiagnosticSignInfo guifg=#658695 guibg=#262636 guisp=NONE blend=NONE gui=NONE
    hi StatusDiagnosticSignWarn guifg=#FF9E3D guibg=#262636 guisp=NONE blend=NONE gui=NONE
    hi StatusDiffAdded guifg=#76956A guibg=#2A2A37 guisp=NONE blend=NONE gui=NONE
    hi StatusDiffChanged guifg=#DCA460 guibg=#2A2A37 guisp=NONE blend=NONE gui=NONE
    hi StatusDiffDeleted guifg=#C34143 guibg=#2A2A37 guisp=NONE blend=NONE gui=NONE
    hi StatusLine guifg=#DDD8BB guibg=#353545 guisp=NONE blend=NONE gui=NONE
    hi StatusLineNC guifg=#54546D guibg=#16161D guisp=NONE blend=NONE gui=NONE
    hi StatuslineBCommand guifg=#BFA36E guibg=#262636 guisp=NONE blend=NONE gui=bold
    hi StatuslineBInsert guifg=#98BC6C guibg=#262636 guisp=NONE blend=NONE gui=bold
    hi StatuslineBNormal guifg=#7D9CD8 guibg=#262636 guisp=NONE blend=NONE gui=bold
    hi StatuslineBNormalInactive guifg=#7D9CD8 guibg=#262636 guisp=NONE blend=NONE gui=bold
    hi StatuslineBReplace guifg=#FFA166 guibg=#262636 guisp=NONE blend=NONE gui=bold
    hi StatuslineBVisual guifg=#957FB8 guibg=#262636 guisp=NONE blend=NONE gui=bold
    hi StatuslineCommand guifg=#1F1F28 guibg=#BFA36E guisp=NONE blend=NONE gui=NONE
    hi StatuslineInsert guifg=#1F1F28 guibg=#98BC6C guisp=NONE blend=NONE gui=NONE
    hi StatuslineNormal guifg=#16161D guibg=#7D9CD8 guisp=NONE blend=NONE gui=NONE
    hi StatuslineNormalInactive guifg=#C8C092 guibg=#7D9CD8 guisp=NONE blend=NONE gui=NONE
    hi StatuslineReplace guifg=#1F1F28 guibg=#FFA166 guisp=NONE blend=NONE gui=NONE
    hi StatuslineVisual guifg=#1F1F28 guibg=#957FB8 guisp=NONE blend=NONE gui=NONE
    hi String guifg=#98BC6C guibg=NONE guisp=NONE blend=NONE gui=italic
    hi Substitute guifg=#DDD8BB guibg=#C34143 guisp=NONE blend=NONE gui=NONE
    hi TabLine guifg=#928AA8 guibg=#16161D guisp=NONE blend=NONE gui=NONE
    hi TabLineFill guifg=NONE guibg=#1F1F28 guisp=NONE blend=NONE gui=NONE
    hi TabLineSel guifg=#C8C092 guibg=#2A2A37 guisp=NONE blend=NONE gui=NONE
    hi TelescopeBorder guifg=#2A2A37 guibg=#181820 guisp=NONE blend=NONE gui=NONE
    hi TelescopePreviewBorder guifg=#181820 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi TelescopePromptBorder guifg=#2A2A37 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi TelescopeResultsBorder guifg=#1B1B23 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi TelescopeResultsNormal guifg=#C8C092 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi TelescopeSelectionCaret guifg=#FF9E3D guibg=NONE guisp=NONE blend=NONE gui=bold
    hi TermCursor guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=reverse
    hi TermCursorNC guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Title guifg=#7D9CD8 guibg=NONE guisp=NONE blend=NONE gui=bold
    hi Todo guifg=#223249 guibg=#658695 guisp=NONE blend=NONE gui=bold
    hi TreesitterContextLineNumber guifg=#928AA8 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Type guifg=#7AA89F guibg=NONE guisp=NONE blend=NONE gui=nocombine
    hi Underlined guifg=#81B4CA guibg=NONE guisp=NONE blend=NONE gui=underline
    hi WinSeparator guifg=#353545 guibg=#353545 guisp=NONE blend=NONE gui=NONE
    hi Visual guifg=NONE guibg=#223249 guisp=NONE blend=NONE gui=NONE
    hi WarningMsg guifg=#FF9E3D guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Whitespace guifg=#353545 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi WinBar guifg=#C8C092 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi WinBarNC guifg=#C8C092 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi Yank guifg=#C8C092 guibg=#581DBF guisp=NONE blend=NONE gui=NONE
    hi lCursor guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi statuslineRegister guifg=#16161D guibg=#7D9CD8 guisp=NONE blend=NONE gui=bold
    hi statuslineRegisterRecording guifg=#D8E4D9 guibg=#E82626 guisp=NONE blend=NONE gui=bold
    hi @comment.gitcommit guifg=#727169 guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @constant.builtin guifg=#FFA166 guibg=NONE guisp=NONE blend=NONE gui=bold,italic
    hi @constructor guifg=#7D9CD8 guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @function.builtin guifg=#7D9CD8 guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @keyword.import guifg=#E46776 guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @keyword.nullptr guifg=#957FB8 guibg=NONE guisp=NONE blend=NONE gui=italic,nocombine
    hi @keyword.return guifg=#E04D5E guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @lsp.type.keyword guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi @lsp.type.variable guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi @markup.heading.gitcommit guifg=#7D9CD8 guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi @markup.link.url.markdown_inline guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
    hi @namespace guifg=#DDD8BB guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @type.builtin guifg=#7AA89F guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @variable.builtin guifg=#957FB8 guibg=NONE guisp=NONE blend=NONE gui=italic
    hi @variable.builtin.vim guifg=#81B4CA guibg=NONE guisp=NONE blend=NONE gui=italic
endfunction

if &background == "light"
    call s:kanagawa_light()
else
    call s:kanagawa_dark()
endif

hi! link Delimiter Normal
hi! link BlinkCmpDocBorder CmpDocumentationBorder
hi! link BlinkCmpDoc CmpDocumentation
hi! link BlinkCmpGhostText Comment
hi! link BlinkCmpItemAbbr CmpItemAbbr
hi! link BlinkCmpItemAbbrDeprecated CmpItemAbbrDeprecated
hi! link BlinkCmpItemAbbrMatch CmpItemAbbrMatch
hi! link BlinkCmpItemAbbrMatchFuzzy CmpItemAbbrMatchFuzzy
hi! link BlinkCmpItemKindDefault CmpItemKindDefault
hi! link BlinkCmpItemMenu CmpItemMenu
hi! link BlinkCmpKindClass CmpItemKindClass
hi! link BlinkCmpKindClassSel BlinkCmpKindClass
hi! link BlinkCmpKindColor CmpItemKindColor
hi! link BlinkCmpKindColorSel BlinkCmpKindColor
hi! link BlinkCmpKindConstant CmpItemKindConstant
hi! link BlinkCmpKindConstantSel BlinkCmpKindConstant
hi! link BlinkCmpKindConstructor CmpItemKindConstructor
hi! link BlinkCmpKindConstructorSel BlinkCmpKindConstructor
hi! link BlinkCmpKindCopilot CmpItemKindCopilot
hi! link BlinkCmpKindCopilotSel BlinkCmpKindCopilot
hi! link BlinkCmpKindEnum CmpItemKindEnum
hi! link BlinkCmpKindEnumMember CmpItemKindEnumMember
hi! link BlinkCmpKindEnumMemberSel BlinkCmpKindEnumMember
hi! link BlinkCmpKindEnumSel BlinkCmpKindEnum
hi! link BlinkCmpKindEvent CmpItemKindEvent
hi! link BlinkCmpKindEventSel BlinkCmpKindEvent
hi! link BlinkCmpKindField CmpItemKindField
hi! link BlinkCmpKindFieldSel BlinkCmpKindField
hi! link BlinkCmpKindFile CmpItemKindFile
hi! link BlinkCmpKindFileSel BlinkCmpKindFile
hi! link BlinkCmpKindFolder CmpItemKindFolder
hi! link BlinkCmpKindFolderSel BlinkCmpKindFolder
hi! link BlinkCmpKindFunction CmpItemKindFunction
hi! link BlinkCmpKindFunctionSel BlinkCmpKindFunction
hi! link BlinkCmpKindInterface CmpItemKindInterface
hi! link BlinkCmpKindInterfaceSel BlinkCmpKindInterface
hi! link BlinkCmpKindKeyword CmpItemKindKeyword
hi! link BlinkCmpKindKeywordSel BlinkCmpKindKeyword
hi! link BlinkCmpKindMethod CmpItemKindMethod
hi! link BlinkCmpKindMethodSel BlinkCmpKindMethod
hi! link BlinkCmpKindModule CmpItemKindModule
hi! link BlinkCmpKindModuleSel BlinkCmpKindModule
hi! link BlinkCmpKindOperator CmpItemKindOperator
hi! link BlinkCmpKindOperatorSel BlinkCmpKindOperator
hi! link BlinkCmpKindProperty CmpItemKindProperty
hi! link BlinkCmpKindPropertySel BlinkCmpKindProperty
hi! link BlinkCmpKindReference CmpItemKindReference
hi! link BlinkCmpKindReferenceSel BlinkCmpKindReference
hi! link BlinkCmpKindSnippet CmpItemKindSnippet
hi! link BlinkCmpKindSnippetSel BlinkCmpKindSnippet
hi! link BlinkCmpKindStruct CmpItemKindStruct
hi! link BlinkCmpKindStructSel BlinkCmpKindStruct
hi! link BlinkCmpKindText CmpItemKindText
hi! link BlinkCmpKindTextSel BlinkCmpKindText
hi! link BlinkCmpKindTypeParameter CmpItemKindTypeParameter
hi! link BlinkCmpKindTypeParameterSel BlinkCmpKindTypeParameter
hi! link BlinkCmpKindUnit CmpItemKindUnit
hi! link BlinkCmpKindUnitSel BlinkCmpKindUnit
hi! link BlinkCmpKindValue CmpItemKindValue
hi! link BlinkCmpKindValueSel BlinkCmpKindValue
hi! link BlinkCmpKindVariable CmpItemKindVariable
hi! link BlinkCmpKindVariableSel BlinkCmpKindVariable
hi! link BlinkCmpMenuBorder CmpCompletionBorder
hi! link BlinkCmpMenu CmpCompletion
hi! link BlinkCmpMenuSelection CmpCompletionSel
hi! link BlinkCmpScrollBarGutter CmpCompletionSbar
hi! link BlinkCmpScrollBarThumb CmpCompletionThumb
hi! link @boolean Boolean
hi! link @character Character
hi! link @character.special SpecialChar
hi! link CmpCompletion Pmenu
hi! link CmpCompletionSbar PmenuSbar
hi! link CmpCompletionThumb PmenuThumb
hi! link CmpDocumentationBorder FloatBorder
hi! link CmpDocumentation NormalFloat
hi! link CmpItemAbbrMatchFuzzy CmpItemAbbrMatch
hi! link CmpItemKindDefault MsgArea
hi! link CmpItemMenu MsgArea
hi! link @comment Comment
hi! link @conditional Conditional
hi! link Conditional Keyword
hi! link @constant Constant
hi! link @constant.macro Define
hi! link @constructor.lua Keyword
hi! link CursorColumn CursorLine
hi! link CursorIM Cursor
hi! link CursorLineFold CursorLineNr
hi! link CursorLineSign CursorLineNr
hi! link DapUIBreakpointsDisabledLine Comment
hi! link DapUIBreakpointsInfo DiagnosticInfo
hi! link DapUIBreakpointsPath Directory
hi! link DapUIFloatBorder Special
hi! link DapUILineNumber Special
hi! link DapUIPlayPause String
hi! link DapUIRestart String
hi! link DapUIScope Special
hi! link DapUISource Special
hi! link DapUIStepBack Special
hi! link DapUIStepInto Special
hi! link DapUIStepOut Special
hi! link DapUIStepOver Special
hi! link DapUIStop DiagnosticError
hi! link DapUIStoppedThread Special
hi! link DapUIThread Identifier
hi! link DapUIType Type
hi! link DapUIUnavailable Comment
hi! link DapUIWatchesEmpty DiagnosticError
hi! link DapUIWatchesError DiagnosticError
hi! link DapUIWatchesValue Identifier
hi! link @debug Debug
hi! link Debug Special
hi! link @define Define
hi! link Define PreProc
hi! link DiagnosticFloatingError DiagnosticError
hi! link DiagnosticFloatingHint DiagnosticHint
hi! link DiagnosticFloatingInfo DiagnosticInfo
hi! link DiagnosticFloatingOk DiagnosticOk
hi! link DiagnosticFloatingWarn DiagnosticWarn
hi! link DiagnosticSignError DiagnosticError
hi! link DiagnosticSignHint DiagnosticHint
hi! link DiagnosticSignInfo DiagnosticInfo
hi! link DiagnosticSignOk DiagnosticOk
hi! link DiagnosticSignWarn DiagnosticWarn
hi! link DiagnosticVirtualTextError DiagnosticError
hi! link DiagnosticVirtualTextHint DiagnosticHint
hi! link DiagnosticVirtualTextInfo DiagnosticInfo
hi! link DiagnosticVirtualTextOk DiagnosticOk
hi! link DiagnosticVirtualTextWarn DiagnosticWarn
hi! link DiffAdded DiffAdd
hi! link DiffChanged DiffChange
hi! link DiffDeleted DiffDelete
hi! link DiffRemoved DiffDelete
hi! link @exception Exception
hi! link @field Property
hi! link @float Float
hi! link FloatFooter FloatTitle
hi! link Float Number
hi! link @function Function
hi! link @function.macro Macro
hi! link GitSignsAdd DiffAdded
hi! link GitSignsChange DiffChanged
hi! link GitSignsDelete DiffDeleted
hi! link healthError DiagnosticError
hi! link healthSuccess DiagnosticOk
hi! link healthWarning DiagnosticWarn
hi! link HydraBorder FloatBorder
hi! link HydraFooter FloatFooter
hi! link HydraHint NormalFloat
hi! link HydraTitle FloatTitle
hi! link Ignore NonText
hi! link @include Include
hi! link Include PreProc
hi! link @keyword.conditional Conditional
hi! link @keyword.conditional.ternary Operator
hi! link @keyword Keyword
hi! link @keyword.label Label
hi! link @keyword.operator Operator
hi! link @keyword.repeat Repeat
hi! link @keyword.vim Statement
hi! link Label Keyword
hi! link @label Label
hi! link LineNrAbove LineNr
hi! link LineNrBelow LineNr
hi! link LspCodeLensSeparator LspCodeLens
hi! link @lsp.mod.readonly Constant
hi! link LspReferenceRead LspReferenceText
hi! link @lsp.typemod.keyword.documentation.lua Special
hi! link @lsp.typemod.variable.global Constant
hi! link @lsp.type.namespace @namespace
hi! link @lsp.type.parameter @variable.parameter
hi! link @lsp.type.variable.lua @lsp.type.variable
hi! link @macro Macro
hi! link Macro PreProc
hi! link @markup.italic.markdown_inline Exception
hi! link @markup.link.label.markdown_inline Property
hi! link @markup.list.markdown Function
hi! link @markup.raw.markdown_inline String
hi! link @method Function
hi! link MiniClueBorder FloatBorder
hi! link MiniClueDescGroup DiagnosticFloatingWarn
hi! link MiniClueDescSingle NormalFloat
hi! link MiniClueNextKey DiagnosticFloatingHint
hi! link MiniClueNextKeyWithPostkeys DiagnosticFloatingError
hi! link MiniClueSeparator DiagnosticFloatingInfo
hi! link MiniClueTitle FloatTitle
hi! link MiniDiffSignAdd DiffAdd
hi! link MiniDiffSignChange DiffChange
hi! link MiniDiffSignDelete DiffDelete
hi! link MiniIndentscopeSymbol Special
hi! link MiniOperatorsExchangeFrom IncSearch
hi! link MiniSurround IncSearch
hi! link @module @namespace
hi! link MultiCursorDisabledCursor Visual
hi! link MultiCursorDisabledVisual Visual
hi! link MultiCursorVisual Visual
hi! link NeogitCommitViewHeader DiffText
hi! link NeogitDiffContextHighlight Normal
hi! link NeogitHunkHeaderCursor NeogitHunkHeaderHighlight
hi! link NeogitHunkHeader Function
hi! link NoiceCmdline MiniStatuslineDevinfoB
hi! link NormalNC Normal
hi! link @number Number
hi! link @operator Operator
hi! link @parameter Identifier
hi! link PreCondit PreProc
hi! link @preproc PreProc
hi! link @property Property
hi! link @punctuation Delimiter
hi! link Question MoreMsg
hi! link Repeat Keyword
hi! link @repeat Repeat
hi! link SpecialChar Special
hi! link SpecialComment Operator
hi! link SpecialComment Special
hi! link Statement Keyword
hi! link @storageclass StorageClass
hi! link StorageClass Type
hi! link @string.escape Operator
hi! link @string.regexp Operator
hi! link @string.special SpecialChar
hi! link @string String
hi! link @structure Structure
hi! link Structure Type
hi! link Tag Special
hi! link @tag Tag
hi! link TelescopeResultsClass Structure
hi! link TelescopeResultsField @field
hi! link TelescopeResultsMethod Function
hi! link TelescopeResultsStruct Structure
hi! link TelescopeResultsVariable @variable
hi! link TelescopeSelection CursorLine
hi! link TelescopeTitle Title
hi! link @text.literal String
hi! link @text.reference Identifier
hi! link @text.title Title
hi! link @text.todo Todo
hi! link @text.underline Underlined
hi! link @text.uri Underlined
hi! link TreesitterContext Folded
hi! link @type.definition Typedef
hi! link Typedef Type
hi! link @type Type
hi! link @variable Identifier
hi! link @variable.member Property
hi! link @variable.parameter @parameter
hi! link VisualNOS Visual
hi! link WildMenu Pmenu
hi! link VertSplit WinSeparator
