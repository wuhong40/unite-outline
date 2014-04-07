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
    \ 'heading': '\%(\<function\>\|\<intrinsic\>\)',
    \ 'highlight_rules': [
    \   { 
    \     'name' : 'function',
    \     'pattern' : '/function\|intrinsic/' 
    \   },
    \   { 
    \     'name' : 'parameter_list',
    \     'pattern' : '/(.*)/',
    \     'highlight' : 'type' 
    \   },
    \ ],
    \ 'is_volatile': 1,
    \}

function! s:outline_info.create_heading(which, heading_line, matched_line, context)
  let heading = {
      \ 'word' : a:heading_line,
      \ 'level' : 1,
      \ 'type' : 'generic',
      \}

  if a:heading_line =~ '^\s*\<intrinsic\>'
    let heading.word = 'intrinsic ' 
    let heading.word .= matchstr(a:heading_line, 
            \'^\s*intrinsic\s*\zs[0-9a-zA-Z]\+\ze(')
    let heading.word .= ' (' . matchstr(a:heading_line, 
            \'^\s*intrinsic\s*[0-9a-zA-Z]\+(\zs[0-9a-zA-Z, :=]*\ze)') . ')'
    let heading.type = 'function'
  elseif a:heading_line =~ '^\s*\<function\>'
    let heading.word = 'function ' 
    let heading.word .= matchstr(a:heading_line, 
            \'^\s*function\s*\zs[0-9a-zA-Z]\+\ze(')
    let heading.word .= ' (' . matchstr(a:heading_line, 
            \'^\s*function\s*[0-9a-zA-Z]\+(\zs[0-9a-zA-Z, :=]*\ze)') . ')'
    let heading.type = 'function'
  elseif a:heading_line =~ ':=\s*\<function\>'
    let heading.word = 'function ' 
    let heading.word .= matchstr(a:heading_line, 
            \'^\s*\zs[0-9a-zA-Z]\+\ze\s*:=')
    let heading.word .= ' (' . matchstr(a:heading_line, 
            \'\<function\s*(\zs[0-9a-zA-Z, :=]*\ze)') . ')'
    let heading.type = 'level_6'
  else
    return {}
  endif

  return heading
endfunction
