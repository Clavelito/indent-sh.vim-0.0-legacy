" Vim indent file
" Language:         Shell Script
" Author:           Clavelito <maromomo@hotmail.com>
" Last Change:      Tue, 01 Mar 2022 10:23:55 +0900
" Version:          0.0-legacy
" License:          http://www.apache.org/licenses/LICENSE-2.0
"
" Description:      This is not a gg=G filter.
"                   This is a very simplified version.


if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetShInd()
setlocal indentkeys+=0=elif,0=fi,0=esac,0=done,0)
setlocal indentkeys-=:,0#
let b:undo_indent = 'setlocal indentexpr< indentkeys<'

if exists('*GetShInd')
  finish
endif
let s:cpo_save = &cpo
set cpo&vim

function GetShInd()
  let lnum = prevnonblank(v:lnum - 1)
  let line = getline(lnum)
  while lnum > 0 && s:Comment(line)
    let lnum = prevnonblank(lnum - 1)
    let line = getline(lnum)
  endwhile
  let cline = getline(v:lnum)
  if lnum == 0 || cline =~ '^#'
    return 0
  endif
  let pnum = prevnonblank(lnum - 1)
  let pline = getline(pnum)
  while pnum > 0 && s:Comment(pline)
    let pnum = prevnonblank(pnum - 1)
    let pline = getline(pnum)
  endwhile
  let ind = indent(lnum)
  if (s:Continue(pline) || s:Bar(pline)) && !s:Continue(line) && !s:Bar(line)
    while pnum > 0 && (s:Comment(pline) || s:Continue(pline) || s:Bar(pline))
      if !s:Comment(pline)
        let ind = indent(pnum)
      endif
      if s:Esac(pline)
        break
      endif
      let pnum = prevnonblank(pnum - 1)
      let pline = getline(pnum)
    endwhile
  endif
  if (s:CaseStart(pline) || s:CaseEnd(pline))
        \ && !s:Esac(line) && !s:Backslash(line)
        \ || !s:Backslash(pline) && s:Backslash(line) && !s:CaseStart(pline)
        \ && (!s:CaseEnd(pline) || s:CaseEnd(pline) && s:Esac(line))
    let ind += shiftwidth()
  elseif s:ExprCont(pline) && !s:Continue(line)
    let ind = indent(pnum)
  endif
  if s:CaseStart(line)
        \ || s:ExprCont(line)
        \ || line =~# '[]});]\s*\%(do\|then\)\%(\s\|$\)'
        \ || line =~# '^\s*\%(do\|then\|else\)\%(\s\|$\)'
        \ || line =~# '\<\%(for\|select\)\s\+\h\w*\s\+do\%(\s\|$\)'
        \ || line =~# '^\s*\%(if\|elif\|while\|until\)\s' && s:Continue(line)
        \ || line =~ '^[^#]*[$\\]\@1<!{\s*\%(#[^}]*\)\=$'
        \ || line =~ '^[^#]*\\\@1<!((\=\s*\%(#[^)]*\)\=$'
    let ind += shiftwidth()
  endif
  if line =~# '[;&})]\s*\%(done\|fi\)\>'
    let ind -= shiftwidth()
  endif
  if s:CaseEnd(line)
    let ind -= shiftwidth()
  endif
  if s:Esac(cline)
    let ind -= s:CaseEnd(line) ? shiftwidth() : shiftwidth() * 2
  elseif cline =~# '^\s*\%(done\|fi\)\>'
        \ || cline =~# '^\s*\%(elif\|else\)\%(\s\|$\)'
        \ || cline =~ '^\s*[})]'
    let ind -= shiftwidth()
  endif
  return ind
endfunction

function s:Continue(line)
  return s:AndOr(a:line) || s:Backslash(a:line)
endfunction

function s:AndOr(line)
  return a:line =~ '\%(&&\|||\)\s*\%(#.*\|\\\)\=$'
endfunction

function s:Backslash(line)
  return a:line =~ '\\\@1<!\%(\\\\\)*\\$'
endfunction

function s:Bar(line)
  return a:line =~ '\%([;|]\@1<!\&\\\@1<!\%(\\\\\)*\)|&\=\s*\%(#.*\|\\\)\=$'
endfunction

function s:ExprCont(line)
  return a:line =~# '^\s*\%(if\|elif\|while\|until\)\%(\s*\\\=\|\s\+#.*\)$'
endfunction

function s:CaseStart(line)
  return a:line =~# '\<case\s.*\sin\%(\s*\|\s\+#.*\)$'
endfunction

function s:CaseEnd(line)
  return a:line =~ ';[;&|]\s*\%(#.*\)\=$'
endfunction

function s:Esac(line)
  return a:line =~# '^\s*esac\>'
endfunction

function s:Comment(line)
  return a:line =~ '^\s*#'
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
