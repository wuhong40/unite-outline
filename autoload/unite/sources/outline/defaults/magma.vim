"=============================================================================
" File    : autoload/unite/sources/outline/defaults/magma.vim
" Author  : Sebastian Jambor <s.jambor@auckland.ac.nz>
" Updated : 2014-04-07
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

" Default outline info for Magma files
" Version: 0.1.0

function! unite#sources#outline#defaults#magma#outline_info()
  return s:outline_info
endfunction

let s:Util = unite#sources#outline#import('Util')

"-----------------------------------------------------------------------------
" Outline Info

let s:outline_info = {
    \ 'heading': '\%(\<function\>\|\<intrinsic\>\|\<procedure\>\)',
    \ 'highlight_rules': [
    \   { 
    \     'name' : 'function',
    \     'pattern' : '/function\|intrinsic\|procedure/' 
    \   },
    \   { 
    \     'name' : 'parameter_list',
    \     'pattern' : '/(.*)/',
    \     'highlight' : 'type' 
    \   },
    \ ],
    \ 'is_volatile': 1,
    \}

" Identifiers (names for user variables, functions etc.) must begin with a
" letter, and this letter may be followed by any combination of letters or
" digits, provided that the name is not a reserved word (see the chapter on
" reserved words a complete list). In this definition the underscore _ is
" treated as a letter.
let s:identifierRegex = '\h[0-9a-zA-Z_]*'
let s:paramRegex = '[0-9a-zA-Z, :=_\[\]~{}<>@\*]*'


function! s:outline_info.create_heading(
    \which, heading_line, matched_line, context)
  let heading = {
      \ 'word' : a:heading_line,
      \ 'level' : 1,
      \ 'type' : 'function',
      \}

  if a:heading_line =~ '^\s*\<intrinsic\>'
    " intrinsic <name> (<parameter_list>)
    let type = 'intrinsic'
    let func_name = matchstr(a:heading_line, 
        \'^\s*intrinsic\s*\zs' . s:identifierRegex . '\ze\s*(')
  elseif a:heading_line =~ '^\s*\<function\>'
    " function <name> (<parameter_list>)
    let type = 'function' 
    let func_name = matchstr(a:heading_line, 
        \'^\s*function\s*\zs' . s:identifierRegex . '\ze\s*(')
  elseif a:heading_line =~ '^\s*\<procedure\>'
    " procedure <name> (<parameter_list>)
    let type = 'procedure' 
    let func_name = matchstr(a:heading_line, 
        \'^\s*procedure\s*\zs' . s:identifierRegex . '\ze\s*(')
  elseif a:heading_line =~ ':=\s*\%\(\<function\>\|\<procedure\>\)'
    " <name> := function(<parameter_list>)
    " or
    " <name> := procedure(<parameter_list>)
    let type = matchstr(a:heading_line, '\%\(\<function\>\|\<procedure\>\)') 
    let func_name = matchstr(a:heading_line, 
        \'^\s*\zs' . s:identifierRegex . '\ze\s*:=')
  else
    return {}
  endif

  let arg_list = matchstr(a:heading_line, '(\zs' . s:paramRegex . '\ze)') 

  let heading.word = type . ' ' . func_name . '(' . arg_list . ')'

  return heading
endfunction
