" vim: ft=vim

if exists("clang++")
  finish
endif
let current_compiler = "clang++"
CompilerSet makeprg=clang++

let s:cpo_save = &cpo
set cpo-=C

setlocal errorformat=%f:%l:%c:\ %t%s:\ %m

let &cpo = s:cpo_save
unlet s:cpo_save
