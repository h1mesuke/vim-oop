"=============================================================================
" vim-oop
" Class-based OOP Layer for Vimscript <Mininum Edition>
"
" File    : oop.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-27
" Version : 0.1.0
" License : MIT license {{{
"
"   Permission is hereby granted, free of charge, to any person obtaining
"   a copy of this software and associated documentation files (the
"   "Software"), to deal in the Software without restriction, including
"   without limitation the rights to use, copy, modify, merge, publish,
"   distribute, sublicense, and/or sell copies of the Software, and to
"   permit persons to whom the Software is furnished to do so, subject to
"   the following conditions:
"
"   The above copyright notice and this permission notice shall be included
"   in all copies or substantial portions of the Software.
"
"   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:initialized = 0

function! oop#initialize()
  if s:initialized
    return
  endif
  call oop#class#_initialize()
  let s:initialized = 1
endfunction

function! oop#is_object(obj)
  return (type(a:obj) == type({}) && has_key(a:obj, 'class') &&
        \ type(a:obj.class) == type({}) && has_key(a:obj.class, 'class') &&
        \ a:obj.class.class is oop#class#get('Class'))
endfunction

function! oop#is_class(obj)
  return (oop#is_object(a:obj) && a:obj.class is oop#class#get('Class'))
endfunction

function! oop#is_instance(obj)
  return (oop#is_object(a:obj) && a:obj.class isnot oop#class#get('Class'))
endfunction

function! oop#inspect(value)
  if oop#is_object(a:value)
    return a:value.inspect()
  else
    return string(a:value)
  endif
endfunction

function! oop#to_s(value)
  if oop#is_object(a:value)
    return a:value.to_s()
  else
    return string(a:value)
  endif
endfunction

" vim: filetype=vim
