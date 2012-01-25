"=============================================================================
" vim-oop
" OOP Support for Vim script
"
" File    : oop/class.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2012-01-25
" Version : 0.2.4
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

let s:save_cpo = &cpo
set cpo&vim

let s:TYPE_NUM  = type(0)
let s:TYPE_FUNC = type(function('tr'))

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

"-----------------------------------------------------------------------------
" Class

function! oop#class#new(name, sid, ...)
  let class = copy(s:Class)
  let class.name = a:name
  let sid = (type(a:sid) == s:TYPE_NUM ? a:sid : matchstr(a:sid, '\d\+'))
  let class.__prefix__ = printf('<SNR>%d_%s_', sid, a:name)
  "=> <SNR>10_Foo_
  let class.__prototype__ = copy(s:Instance)
  let class.superclass = (a:0 ? a:1 : {})
  " Inherit methods from superclasses.
  for klass in class.ancestors()
    call extend(class, klass, 'keep')
    call extend(class.__prototype__, klass.__prototype__, 'keep')
  endfor
  return class
endfunction

function! oop#class#xnew(...)
  let class = call('oop#class#new', a:000)
  let class.__instanciator__ = 'extend'
  return class
endfunction

let s:Class = copy(oop#__object__())
let s:Class.__instanciator__ = 'copy'

function! s:Class_ancestors() dict
  let ancestors = []
  let klass = self.superclass
  while !empty(klass)
    call add(ancestors, klass)
    let klass = klass.superclass
  endwhile
  return ancestors
endfunction
let s:Class.ancestors = function(s:SID . 'Class_ancestors')

function! s:Class_is_descendant_of(class) dict
  return index(self.ancestors(), a:class) >= 0
endfunction
let s:Class.is_descendant_of = function(s:SID . 'Class_is_descendant_of')

let s:Class.__class_bind__ = s:Class.__bind__

function! s:Class_class_method(func_name, ...) dict
  let func_name = self.__prefix__ . a:func_name
  call call(self.__class_bind__, [func_name] + a:000, self)
endfunction
let s:Class.class_method = function(s:SID . 'Class_class_method')

let s:Class.class_alias = s:Class.alias

function! s:Class_bind(...) dict
  call call(self.__prototype__.__bind__, a:000, self.__prototype__)
endfunction
let s:Class.__bind__ = function(s:SID . 'Class_bind')

function! s:Class_method(func_name, ...) dict
  let func_name = self.__prefix__ . a:func_name
  call call(self.__bind__, [func_name] + a:000, self)
endfunction
let s:Class.method = function(s:SID . 'Class_method')

function! s:Class_alias(...) dict
  call call(self.__prototype__.alias, a:000, self.__prototype__)
endfunction
let s:Class.alias = function(s:SID . 'Class_alias')

function! s:Class_include(...) dict
  call call(self.__prototype__.extend, a:000, self.__prototype__)
endfunction
let s:Class.include = function(s:SID . 'Class_include')

function! s:Class_super(meth_name, args, _self) dict
  let is_class = oop#is_class(a:_self)
  let meth_table = (is_class ? self : self.__prototype__)

  let has_impl = (has_key(meth_table, a:meth_name) &&
        \ type(meth_table[a:meth_name]) == s:TYPE_FUNC)

  for klass in self.ancestors()
      let kls_meth_table = (is_class ? klass : klass.__prototype__)
    if has_key(kls_meth_table, a:meth_name)
      if type(kls_meth_table[a:meth_name]) != s:TYPE_FUNC
        let sep = (is_class ? '.' : '#')
        throw "vim-oop: " . klass.name . sep . a:meth_name . " is not a method."
      elseif !has_impl || (has_impl && meth_table[a:meth_name] != kls_meth_table[a:meth_name])
        return call(kls_meth_table[a:meth_name], a:args, a:_self)
      endif
    endif
  endfor
  let sep = (is_class ? '.' : '#')
  throw "vim-oop: " . self.name . sep .
        \ a:meth_name . "()'s super implementation was not found."
endfunction
let s:Class.super = function(s:SID . 'Class_super')

function! s:Class_new(...) dict
  if self.__instanciator__ ==# 'extend'
    let obj = extend(a:000[0], self.__prototype__, 'keep')
    let args = a:000[1:-1]
  else
    let obj = copy(self.__prototype__)
    let args = a:000
  endif
  let obj.class = self
  call call(obj.initialize, args, obj)
  return obj
endfunction
let s:Class.new = function(s:SID . 'Class_new')

function! s:Class___promote__(attrs) dict
  let obj = extend(a:attrs, self.__prototype__, 'keep')
  let obj.class = self
  return obj
endfunction
let s:Class.__promote__ = function(s:SID . 'Class___promote__')

"-----------------------------------------------------------------------------
" Instance

let s:Instance = copy(oop#__object__())

function! s:Instance_initialize(...) dict
endfunction
let s:Instance.initialize = function(s:SID . 'Instance_initialize')

function! s:Instance_is_kind_of(class) dict
  return (self.class is a:class || self.class.is_descendant_of(a:class))
endfunction
let s:Instance.is_kind_of = function(s:SID . 'Instance_is_kind_of')
let s:Instance.is_a = function(s:SID . 'Instance_is_kind_of')

function! s:Instance___demote__() dict
  let self.class = self.class.name
  call filter(self, 'type(v:val) != s:TYPE_FUNC')
  call remove(self, '__vim_oop__')
  return self
endfunction
let s:Instance.__demote__ = function(s:SID . 'Instance___demote__')

function! s:Instance_serialize() dict
  return oop#string(self)
endfunction
let s:Instance.serialize = function(s:SID . 'Instance_serialize')

let &cpo = s:save_cpo
