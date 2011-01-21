"=============================================================================
" Simple OOP Layer for Vimscript
"
" File    : oop.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-21
" Version : 0.0.6
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

function! oop#is_class(obj)
  return (type(a:obj) == type({}) && has_key(a:obj, 'class') && a:obj.class is oop#class#get('Class'))
endfunction

function! oop#is_instance(obj)
  return (type(a:obj) == type({}) && has_key(a:obj, 'class') && oop#is_class(a:obj.class))
endfunction

function! oop#is_object(obj)
  return (oop#is_instance(a:obj) || oop#is_class(a:obj))
endfunction

" vim: filetype=vim
