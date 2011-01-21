"=============================================================================
" Simple OOP Layer for Vimscript
"
" File    : oop/object.vim
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

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()

let s:Object = oop#class#new('Object', '__nil__')

function! s:Object_initialize(...) dict
endfunction
call s:Object.bind(s:SID, 'initialize')

function! s:Object_is_a(class) dict
  if oop#is_class(a:class)
    let kind_class = a:class
  elseif type(a:class) == type("")
    let kind_class = oop#class#get(a:class)
  else
    throw "oop: class required, but got " . string(a:class)
  endif
  let class = self.class
  while !empty(class)
    if class is kind_class
      return 1
    endif
    let class = class.superclass
  endwhile
  return 0
endfunction
call s:Object.bind(s:SID, 'is_a')

function! s:Object_super(method_name, ...) dict
  let defined_here = (has_key(self, a:method_name) &&
        \ type(self[a:method_name]) == type(function('tr')))
  let class = self.class
  while !empty(class)
    if has_key(class.prototype, a:method_name)
      if type(class.prototype[a:method_name]) != type(function('tr'))
        throw "oop: " . class.name . "#" . a:method_name . " is not a method"
      elseif !defined_here ||
            \ (defined_here && self[a:method_name] != class.prototype[a:method_name])
        return call(class.prototype[a:method_name], a:000, self)
      endif
    endif
    let class = class.superclass
  endwhile
  throw "oop: " . self.class.name . "#" . a:method_name . "()'s super implementation was not found"
endfunction
call s:Object.bind(s:SID, 'super')

function! s:Object_to_s() dict
  return '<' . self.class.name . ':0x' . printf('%08x', self.object_id) . '>'
endfunction
call s:Object.bind(s:SID, 'to_s')

" vim: filetype=vim
