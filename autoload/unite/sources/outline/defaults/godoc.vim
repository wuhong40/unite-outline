"=============================================================================
" File    : autoload/unite/sources/outline/defaults/go.vim
" Author  : rhysd <lin90162@yahoo.co.jp>
" Updated : 2015-04-25
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

" Default outline info for Go

function! unite#sources#outline#defaults#godoc#outline_info()
    return s:outline_info
endfunction

let s:Util = unite#sources#outline#import('Util')

let s:outline_info = {
            \ 'heading' : '^\%(\u[[:upper:] ]*\|\%(package\|func\|type\|var\)\s\+.\+\)$',
            \ 'highlight_rules' : [
            \   {
            \       'name' : 'title',
            \       'pattern' : '/\<\u\+\>/',
            \       'highlight' : 'Title',
            \   },
            \   {
            \       'name' : 'function',
            \       'pattern' : '/\%(([^)]*)\s\+\)\=\zs\h\w*\ze\s*([^)]*) : function/',
            \   },
            \   {
            \       'name' : 'type',
            \       'pattern' : '/\<\h\w*\ze : \%(interface\|struct\|type\)\>/',
            \   },
            \   {
            \       'name' : 'variable',
            \       'pattern' : '/\<\h\w*\ze : variable/',
            \       'highlight' : 'Identifier',
            \   },
            \   {
            \       'name' : 'keyword',
            \       'pattern' : '/\<\%(function\|type\|struct\|interface\|variable\|package\)\>/',
            \       'highlight' : 'Keyword',
            \   },
            \   {
            \       'name' : 'package',
            \       'pattern' : '/\<\h\w*\ze : package\>/',
            \       'highlight' : 'PreProc',
            \   },
            \ ],
            \ }

function! s:outline_info.create_heading(which, heading_line, matched_line, context)
    if a:which != 'heading'
        return {}
    endif

    if a:heading_line =~# '^\u[[:upper:] ]*$'
        return {'word' : a:heading_line, 'type' : 'title', 'level' : 1}
    endif

    if a:heading_line =~# '^type\>'
        let matches = matchlist(a:heading_line, '^type\s\+\(\h\w*\)\s\+\([[:alpha:][\]_][[:alnum:][\]_]*\)')
        if matches[2] =~# '^\%(interface\|struct\)$'
            let type = matches[2]
            let word = matches[1] . ' : ' . matches[2]
        else
            let type = 'type'
            let word = matches[1] . ' : type'
        endif
    elseif a:heading_line =~# '^func\>'
        let type = 'function'
        let word = matchstr(a:heading_line, '^func\s\+\zs\%(([^)]*)\s\+\)\=\h\w*\s*([^)]*)') . ' : function'
    elseif a:heading_line =~# '^var\>'
        let type = 'variable'
        let word = matchstr(a:heading_line, '^var\s\+\zs\h\w*') . ' : variable'
    elseif a:heading_line =~# '^package\>'
        let type = 'package'
        let word = matchstr(a:heading_line, '^package\s\+\zs\h\w*') . ' : package'
    else
        return {}
    endif

    return {'word' : word, 'level' : 2, 'type' : type}
endfunction
