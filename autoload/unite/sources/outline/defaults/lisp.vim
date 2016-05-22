"=============================================================================
" File    : autoload/unite/sources/outline/defaults/lisp.vim
" Author  : adolenc <andrej.dolenc@student.uni-lj.si>
" Updated : 2016-04-08
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

function! unite#sources#outline#defaults#lisp#outline_info() abort
  return s:outline_info
endfunction

let s:Util = unite#sources#outline#import('Util')

"-----------------------------------------------------------------------------
" Outline Info

let s:outline_info = {
      \ 'heading'  : '^(\|^\s*(\(\S*:\)\?def\S*', 
      \
      \ 'skip': {
      \   'header': '^;',
      \   'block': ['^\s*"', '[^\\]"'],
      \ },
      \
      \ 'not_match_patterns': [
      \   s:Util.shared_pattern('*', 'parameter_list'),
      \ ],
      \
      \ 'heading_groups': {
      \   'function'           : ['defun', 'defmacro', 'defgeneric', 'defmethod'],
      \   'variable'           : ['defvar', 'defparameter', 'defconstant'],
      \   'type'               : ['defclass', 'defstruct', 'define-condition', 'deftype'],
      \   'method-combination' : ['define-method-combination'],
      \   'compiler-macro'     : ['define-compiler-macro'],
      \   'package'            : ['defpackage'],
      \ },
      \
      \ 'highlight_rules': [
      \   { 'name'     : 'type',
      \     'pattern'  : '/ :: \zs.*\ze/' },
      \   { 'name'     : 'function',
      \     'pattern'  : '/ \zs.*\ze :: /' },
      \   { 'name'     : 'special',
      \     'pattern'  : '/.* :: top-level form/' },
      \ ],
      \}

function! s:outline_info.create_heading(which, heading_line, matched_line, context) abort
  let h_lnum = a:context.heading_lnum
  let heading = {
        \ 'word' : s:splice_form(a:heading_line),
        \ 'level': s:Util.get_indent_level(a:context, h_lnum),
        \ 'type' : matchstr(a:heading_line, '^\s*(\zs\S\+\ze'),
        \ }
  let form_args = matchstr(heading.word, '^\S\+\s\+\zs.*')

  " If we are checking a def* or a top-level form, fix the heading by
  " appending the proper type after `::'.
  if heading.type =~ '^\(\S\+::\?\)\?def.*'
    let heading.word = s:add_ldots(form_args) . ' :: ' . heading.type
  elseif a:heading_line =~ '^('
    let heading.word = s:add_ldots(heading.word) . ' :: top-level form'
  endif
  return heading
endfunction

function! s:count_occurences(char, string) abort
  " Count number of occurences of {char} in {string}.
  return len(split(a:string, a:char, 1)) - 1
endfunction

function! s:has_balanced_chars(line, open, close) abort
  " Check whether {line} has balanced {open} and {close} characters.
  " Actually just fake it by checking if they appear same number of times
  let n_open_chars = s:count_occurences(a:open, a:line)
  if a:open == a:close
    return (n_open_chars % 2) == 0
  endif
  let n_close_chars = s:count_occurences(a:close, a:line)
  return n_open_chars == n_close_chars
endfunction

function! s:splice_form(line) abort
  " Remove the outermost parentheses from {line}.
  if s:has_balanced_chars(a:line, '(', ')')
    return matchstr(a:line, '^\s*(\zs.*\ze)\s*$')
  else
    return matchstr(a:line, '^\s*(\zs.*')
  endif
endfunction

function! s:add_ldots(line) abort
  " Add `...' to the end of {line} in case it has unbalanced parentheses or
  " quotes.
  if !s:has_balanced_chars(a:line, '(', ')') || !s:has_balanced_chars(a:line, '"', '"')
    return a:line . ' ...'
  endif
  return a:line
endfunction
