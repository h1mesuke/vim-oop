"=============================================================================
" Simple OOP Layer for Vimscript
"
" File    : oop/class.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-18
" Version : 0.0.1
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

let s:Class = { 'prototype': {} }

function! oop#class#new(...)
  let _self = deepcopy(s:Class, 1)
  let _self.class = s:Class
  let _self.super = (a:0 ? a:1 : oop#object#class())
  " inherit methods from superclasses
  let class = _self.super
  while !empty(class)
    call extend(_self, class, 'keep')
    call extend(_self.prototype, class.prototype, 'keep')
    let class = class.super
  endwhile
  return _self
endfunction

function! s:Class.new(...)
  " instantiate
  let obj = copy(self.prototype)
  let obj.class = self
  call call(obj.initialize, a:000, obj)
  return obj
endfunction

function! s:Class.prototype.initialize(...)
endfunction

function! s:Class.prototype.is_a(class)
  let class = self.class
  while !empty(class)
    if class is a:class
      return 1
    endif
    let class = class.super
  endwhile
  return 0
endfunction

" vim: filetype=vim
