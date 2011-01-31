"=============================================================================
" vim-oop
" Class-based OOP Layer for Vimscript
"
" File    : oop/object.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-31
" Version : 0.1.5
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

function! oop#object#_initialize()
  let SID = s:get_SID()

  let s:object_id = 1001
  let s:Object = oop#class#new('Object', '__nil__')

  call s:Object.bind(SID, 'initialize')
  call s:Object.bind(SID, 'inspect')
  call s:Object.bind(SID, 'is_instance_of')
  call s:Object.bind(SID, 'is_kind_of')
  call s:Object.alias('is_a', 'is_kind_of')
  call s:Object.bind(SID, 'mixin')
  call s:Object.bind(SID, 'to_s')

  return s:Object
endfunction

function! oop#object#_get_object_id()
  let s:object_id += 1
  return s:object_id
endfunction

"-----------------------------------------------------------------------------

function! s:Object_initialize(...) dict
endfunction

function! s:Object_inspect() dict
  let _self = map(copy(self), 'oop#is_object(v:val) ? v:val.to_s() : v:val')
  return string(_self)
endfunction

function! s:Object_is_instance_of(class) dict
  return (self.class is oop#class#get(a:class))
endfunction

function! s:Object_is_kind_of(class) dict
  let kind_class = oop#class#get(a:class)
  for class in self.class.ancestors(1)
    if class is kind_class
      return 1
    endif
  endfor
  return 0
endfunction

function! s:Object_mixin(module, ...) dict
  let module = oop#module#get(a:module)
  let mode = (a:0 ? a:1 : 'force')
  call extend(self, module.methods(), mode)
endfunction

function! s:Object_to_s() dict
  return '<' . self.class.name . ':0x' . printf('%08x', self.object_id) . '>'
endfunction

if !oop#_is_initialized()
  call oop#_initialize()
endif

" vim: filetype=vim
