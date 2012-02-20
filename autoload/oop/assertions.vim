"=============================================================================
" vim-oop
" OOP Support for Vim script
"
" File    : autoload/oop/assertions.vim
" Author  : h1mesuke <himesuke+vim@gmail.com>
" Updated : 2012-01-29
" Version : 0.5.1
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
let s:TYPE_STR  = type('')
let s:TYPE_FUNC = type(function('tr'))
let s:TYPE_LIST = type([])
let s:TYPE_DICT = type({})
let s:TYPE_FLT  = type(0.0)

"-----------------------------------------------------------------------------
" Assertions

function! oop#assertions#export()
  return s:Assertions
endfunction

function! s:define()
  let s:Assertions = oop#module#new('Assertions')
endfunction
call s:define()

function! s:Assertions___typestr__(value)
  let type = type(a:value)
  if type == s:TYPE_NUM
    return 'Number'
  elseif type == s:TYPE_STR
    return 'String'
  elseif type == s:TYPE_FUNC
    return 'Funcref'
  elseif type == s:TYPE_LIST
    return 'List'
  elseif oop#is_class(a:value)
    return 'Class'
  elseif oop#is_instance(a:value)
    return 'Instance'
  elseif oop#is_module(a:value)
    return 'Module'
  elseif type == s:TYPE_DICT
    return 'Dictionary'
  elseif type == s:TYPE_FLT
    return 'Float'
  endif
endfunction
call s:Assertions.function('__typestr__')

function! s:Assertions_assert_is_Object(value, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !oop#is_object(a:value)
    call self.report_failure(
          \ printf("Object expected, but was\n%s", self.__typestr__(a:value)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_is_Object')

function! s:Assertions_assert_is_Class(value, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !oop#is_class(a:value)
    call self.report_failure(
          \ printf("Class expected, but was\n%s", self.__typestr__(a:value)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_is_Class')

function! s:Assertions_assert_is_Instance(value, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !oop#is_instance(a:value)
    call self.report_failure(
          \ printf("Instance expected, but was\n%s", self.__typestr__(a:value)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_is_Instance')

function! s:Assertions_assert_is_Module(value, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !oop#is_module(a:value)
    call self.report_failure(
          \ printf("Module expected, but was\n%s", self.__typestr__(a:value)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_is_Module')

function! s:Assertions_assert_is_kind_of(class, value, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !a:value.is_kind_of(a:class)
    call self.report_failure(
          \ printf("%s is not kind of %s, but was\n%s",
          \   self.__string__(a:value), a:class.name, a:value.class.name),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_is_kind_of')
call s:Assertions.alias('assert_is_a', 'assert_is_kind_of')

function! s:Assertions_assert_is_instance_of(class, value, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:value.class isnot a:class
    call self.report_failure(
          \ printf("%s is not an instance of %s, but was\n%s's instance.",
          \   self.__string__(a:value), a:class.name, a:value.class.name),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_is_instance_of')

function! s:Assertions___string__(value)
  return oop#string(a:value)
endfunction
call s:Assertions.function('__string__')

let &cpo = s:save_cpo
