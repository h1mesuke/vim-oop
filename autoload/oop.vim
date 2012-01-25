"=============================================================================
" vim-oop
" OOP Support for Vim script
"
" File    : oop.vim
" Author  : h1mesuke <himesuke+vim@gmail.com>
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

let s:TYPE_LIST = type([])
let s:TYPE_DICT = type({})
let s:TYPE_FUNC = type(function('tr'))

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

let s:namespace = {}

function! oop#__namespace__()
  return s:namespace
endfunction

function! oop#get(name)
  return get(s:namespace, a:name, {})
endfunction

function! oop#is_object(value)
  return type(a:value) == s:TYPE_DICT && has_key(a:value, '__vim_oop__')
endfunction

function! oop#is_class(value)
  return type(a:value) == s:TYPE_DICT && has_key(a:value, '__vim_oop__') &&
        \ has_key(a:value, '__prototype__')
endfunction

function! oop#is_instance(value)
  return type(a:value) == s:TYPE_DICT && has_key(a:value, '__vim_oop__') &&
        \ has_key(a:value, 'class')
endfunction

function! oop#is_module(value)
  return type(a:value) == s:TYPE_DICT && has_key(a:value, '__vim_oop__') &&
        \ !has_key(a:value, '__prototype__') && !has_key(a:value, 'class')
endfunction

function! oop#string(value)
  let value = a:value
  let type = type(a:value)
  if type == s:TYPE_LIST || type == s:TYPE_DICT
    let value = deepcopy(a:value)
    call s:demote_objects(value)
  endif
  return string(value)
endfunction

function! s:demote_objects(value)
  let type = type(a:value)
  if type == s:TYPE_LIST
    call map(a:value, 's:demote_objects(v:val)')
  elseif type == s:TYPE_DICT
    if has_key(a:value, '__vim_oop__') && has_key(a:value, 'class')
      call a:value.__demote__()
    endif
    call map(values(a:value), 's:demote_objects(v:val)')
  endif
  return a:value
endfunction

function! oop#deserialize(str)
  sandbox let dict = eval(a:str)
  return s:promote_objects(dict)
endfunction

function! s:promote_objects(value)
  let type = type(a:value)
  if type == s:TYPE_LIST
    call map(a:value, 's:promote_objects(v:val)')
  elseif type == s:TYPE_DICT
    if has_key(a:value, 'class')
      let class = oop#class#get(a:value.class)
      call class.__promote__(a:value)
    endif
    call map(values(a:value), 's:promote_objects(v:val)')
  endif
  return a:value
endfunction

"-----------------------------------------------------------------------------
" Object

let s:Object = { '__vim_oop__': 1 }

function! s:Object_bind(func, ...) dict
  if type(a:func) == s:TYPE_FUNC
    let Func = a:func
    let meth_name = a:1
  else
    let Func = function(a:func)
    let meth_name = (a:0 ? a:1 : s:remove_prefix(a:func))
  endif
  let self[meth_name] = Func
  if has_key(self, '__export__')
    call add(self.__export__, meth_name)
  endif
endfunction
let s:Object.__bind__ = function(s:SID . 'Object_bind')

function! s:remove_prefix(func_name)
  return substitute(a:func_name, '^<SNR>\d\+_\%(\u[^_]*_\)\+', '', '')
endfunction

function! s:Object_alias(alias, meth_name) dict
  if has_key(self, a:meth_name) && type(self[a:meth_name]) == s:TYPE_FUNC
    let self[a:alias] = self[a:meth_name]
    if has_key(self, '__export__')
      call add(self.__export__, a:alias)
    endif
  else
    throw "vim-oop: " . a:meth_name . "() is not defined."
  endif
endfunction
let s:Object.alias = function(s:SID . 'Object_alias')

function! s:Object_extend(module, ...) dict
  let mode = (a:0 ? a:1 : 'force')
  let exported = {}
  for func_name in a:module.__export__
    let exported[func_name] = a:module[func_name]
  endfor
  call extend(self, exported, mode)
endfunction
let s:Object.extend = function(s:SID . 'Object_extend')

let s:namespace.Object = s:Object
unlet s:Object

let &cpo = s:save_cpo
