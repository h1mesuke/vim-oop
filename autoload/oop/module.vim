"=============================================================================
" vim-oop
" Class-based OOP Layer for Vimscript
"
" File    : oop/module.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-26
" Version : 0.1.1
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

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

function! oop#module#_initialize()
  let SID = s:get_SID()

  let s:Module = oop#class#new('Module')
  let s:module_table = {}

  call s:Module.class_bind(SID, 'get')
  call s:Module.class_bind(SID, 'is_defined')
  call s:Module.class_bind(SID, 'new')

  call s:Module.bind(SID, 'alias')
  call s:Module.bind(SID, 'bind')
  call s:Module.bind(SID, 'to_s')

  return s:Module
endfunction

function! oop#module#get(...)
  return call(s:Module.get, a:000, s:Module)
endfunction

function! oop#module#is_defined(...)
  return call(s:Module.is_defined, a:000, s:Module)
endfunction

function! oop#module#new(...)
  return call(s:Module.new, a:000, s:Module)
endfunction

"-----------------------------------------------------------------------------

function! s:class_Module_get(name) dict
  if type(a:name) == type("")
    if oop#module#is_defined(a:name)
      return s:module_table[a:name]
    else
      throw "oop: module " . a:name . " is not defined"
    endif
  elseif oop#is_module(a:name)
    return a:name
  else
    throw "oop: module required, but got " . string(a:name)
  endif
endfunction

function! s:class_Module_is_defined(name) dict
  return has_key(s:module_table, a:name)
endfunction

function! s:class_Module_new(name, ...) dict
  let _self = copy(s:Module.prototype)
  let _self.object_id = oop#object#_get_object_id()
  let _self.class = s:Module
  let _self.name  = a:name | let s:module_table[a:name] = _self
  return _self
endfunction

function! s:Module_alias(alias, method_name) dict
  if has_key(self, a:method_name) && type(self[a:method_name]) == type(function('tr'))
    let self[a:alias] = self[a:method_name]
  else
    throw "oop: " . self.name . "." . a:method_name . "() is not defined"
  endif
endfunction

function! s:Module_bind(sid, method_name) dict
  let self[a:method_name] = function(a:sid . self.name . '_' . a:method_name)
endfunction

function! s:Module_to_s() dict
  return self.name
endfunction

if !oop#_is_initialized()
  call oop#_initialize()
endif

" vim: filetype=vim
