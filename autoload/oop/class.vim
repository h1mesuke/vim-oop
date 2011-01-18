"=============================================================================
" Simple OOP Layer for Vimscript
"
" File    : oop/class.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-18
" Version : 0.0.2
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

function! oop#class#is_defined(name)
  return has_key(s:class_table, a:name)
endfunction

function! oop#class#get(name)
  if oop#class#is_defined(a:name)
    return s:class_table[a:name]
  else
    throw "oop#class#get(): class " . a:name . " is not defined"
  endif
endfunction

let s:class_table = {}
let s:Class = { 'prototype': {} }
let s:object_id = 0

function! s:get_object_id()
  let s:object_id += 1
  return s:object_id
endfunction

function! oop#class#new(name, ...)
  let _self = deepcopy(s:Class, 1)
  let _self.object_id = s:get_object_id()
  let _self.class = s:Class
  if a:0
    let _self.super = (type(a:1) == type("") ? oop#class#get(a:1) : a:1)
  else
    let _self.super = oop#class#get('Object')
  endif
  let _self.name  = a:name
  let s:class_table[a:name] = _self
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
  let obj.object_id = s:get_object_id()
  let obj.class = self
  call call(obj.initialize, a:000, obj)
  return obj
endfunction

function! s:Class.to_s()
  return '<Class:' . self.name . '>'
endfunction

" bootstrap
execute 'source' expand('<sfile>:p:h') . '/object.vim'

" vim: filetype=vim
