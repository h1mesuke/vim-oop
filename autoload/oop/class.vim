"=============================================================================
" Simple OOP Layer for Vimscript
"
" File    : oop/class.vim
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

function! oop#class#is_defined(name)
  return has_key(s:class_table, a:name)
endfunction

function! oop#class#get(name)
  if oop#class#is_defined(a:name)
    return s:class_table[a:name]
  else
    throw "oop: class " . a:name . " is not defined"
  endif
endfunction

function! oop#class#new(name, ...)
  let _self = deepcopy(s:Class, 1)
  let _self.object_id = s:get_object_id()
  let _self.class = s:Class
  if a:0
    let superclass = a:1
    if oop#is_class(superclass)
      let _self.superclass = superclass
    elseif type(superclass) == type("")
      let _self.superclass = oop#class#get(superclass)
    else
      throw "oop: class required, but got " . string(superclass)
    endif
  else
    let _self.superclass = oop#class#get('Object')
  endif
  let _self.name  = a:name
  let s:class_table[a:name] = _self
  " inherit methods from superclasses
  let class = _self.superclass
  while !empty(class)
    call extend(_self, class, 'keep')
    call extend(_self.prototype, class.prototype, 'keep')
    let class = class.superclass
  endwhile
  return _self
endfunction

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()

let s:Class = { 'class': {}, 'prototype': {} }
let s:class_table = { 'Class': s:Class, '__nil__': {} }

let s:object_id = 0

function! s:get_object_id()
  let s:object_id += 1
  return s:object_id
endfunction

function! s:Class_class_bind(sid, method_name) dict
  let self[a:method_name] = function(a:sid . self.name . '_class_' . a:method_name)
endfunction
let s:Class.class_bind = function(s:SID . 'Class_class_bind')

function! s:Class_bind(sid, method_name) dict
  let self.prototype[a:method_name] = function(a:sid . self.name . '_' . a:method_name)
endfunction
let s:Class.bind = function(s:SID . 'Class_bind')

function! s:Class_is_a(class) dict
  if a:class is s:Class
    return 1
  elseif type(a:class) == type("")
    return (oop#class#get(a:class) is s:Class)
  else
    throw "oop: class required, but got " . string(a:class)
  endif
endfunction
let s:Class.is_a = function(s:SID . 'Class_is_a')

function! s:Class_new(...) dict
  " instantiate
  let obj = copy(self.prototype)
  let obj.object_id = s:get_object_id()
  let obj.class = self
  call call(obj.initialize, a:000, obj)
  return obj
endfunction
let s:Class.new = function(s:SID . 'Class_new')

function! s:Class_super(method_name, ...) dict
  let defined_here = (has_key(self, a:method_name) &&
        \ type(self[a:method_name]) == type(function('tr')))
  let class = self
  while !empty(class)
    if has_key(class, a:method_name)
      if type(class[a:method_name]) != type(function('tr'))
        throw "oop: " . class.name . "." . a:method_name . " is not a method"
      elseif !defined_here ||
            \ (defined_here && self[a:method_name] != class[a:method_name])
        return call(class[a:method_name], a:000, self)
      endif
    endif
    let class = class.superclass
  endwhile
  throw "oop: " . self.name . "." . a:method_name . "()'s super implementation was not found"
endfunction
let s:Class.super = function(s:SID . 'Class_super')

function! s:Class_to_s() dict
  return '<Class:' . self.name . '>'
endfunction
let s:Class.to_s = function(s:SID . 'Class_to_s')

" bootstrap
execute 'source' expand('<sfile>:p:h') . '/object.vim'

" vim: filetype=vim
