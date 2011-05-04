"=============================================================================
" vim-oop
" Class-based OOP Layer for Vim script
"
" File    : oop.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-05-04
" Version : 0.1.7
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

" Inspired by Yukihiro Nakadaira's nsexample.vim
" https://gist.github.com/867896
"
let s:oop = expand('<sfile>:p:r:gs?[\\/]?#?:s?^.*#autoload#??')
" => path#to#oop

function! {s:oop}#is_object(obj)
  return has_key(a:obj, '__type_Object__')
endfunction

function! {s:oop}#is_class(obj)
  return has_key(a:obj, '__type_Class__')
endfunction

function! {s:oop}#is_instance(obj)
  return has_key(a:obj, '__type_Instance__')
endfunction

function! {s:oop}#is_module(obj)
  return has_key(a:obj, '__type_Module__')
endfunction

function! {s:oop}#string(value)
  if has_key(a:value, '__name__')
    return a:value.__name__
  elseif {s:oop}#is_object(a:value)
    " TODO
    return a:value.to_s()
  else
    return s:safe_dump(a:value)
  endif
endfunction

function! s:safe_dump(value)
  return string(s:_safe_dump(a:value))
endfunction
function! s:_safe_dump(value)
  let value_type = type(a:value)
  if value_type == type({}) || value_type == type([])
    return map(copy(a:value), '{s:oop}#is_object(v:val) ? v:val.to_s() : s:_safe_dump(v:val)')
  else
    return a:value
  endif
endfunction

" vim: filetype=vim
