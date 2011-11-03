" vim-oop's test suite

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

"-----------------------------------------------------------------------------
" Module

"---------------------------------------
" Fizz

let s:Fizz = oop#module#new('Fizz', s:SID)

function! s:Fizz_hello() dict
  return "Fizz's hello"
endfunction
call s:Fizz.function('hello')
call s:Fizz.alias('hi', 'hello')

function! s:Fizz_hello_cn() dict
  return "Fizz's nihao"
endfunction
call s:Fizz.function('hello_cn', 'nihao')

"-----------------------------------------------------------------------------
" Tests

" h1mesuke/vim-unittest - GitHub
" https://github.com/h1mesuke/vim-unittest

let tc = unittest#testcase#new('test_module')

" Module#function()
function! tc.Module_function_should_bind_Funcref_as_module_function()
  call assert#is_Funcref(s:Fizz.hello)
  call assert#equal("Fizz's hello", s:Fizz.hello())
endfunction

function! tc.Module_function_should_bind_Funcref_as_module_function_with_given_name()
  call assert#is_Funcref(s:Fizz.nihao)
  call assert#equal("Fizz's nihao", s:Fizz.nihao())

  call assert#not(has_key(s:Fizz, 'hello_cn'))
endfunction

" Module#alias()
function! tc.Module_alias_should_define_alias_of_module_function()
  call assert#equal(s:Fizz.hello, s:Fizz.hi)
endfunction

" oop#is_object()
function! tc.Fizz_should_be_Object()
  call assert#_(oop#is_object(s:Fizz))
endfunction

" oop#is_module()
function! tc.Fizz_should_be_Module()
  call assert#_(oop#is_module(s:Fizz))
endfunction

" oop#string()
function! tc.test_oop_string()
  call assert#equal('<Module: Fizz>', oop#string(s:Fizz))
endfunction

unlet tc

" vim: filetype=vim
