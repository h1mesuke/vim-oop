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
  return "Fizz"
endfunction
call s:Fizz.function('hello')
call s:Fizz.alias('hi', 'hello')

"-----------------------------------------------------------------------------
" Tests

" h1mesuke/vim-unittest - GitHub
" https://github.com/h1mesuke/vim-unittest

let tc = unittest#testcase#new('test_module')

" Module#function()
function! tc.Module_function_should_bind_Funcref_as_module_function()
  call assert#equal("Fizz", s:Fizz.hello())
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

unlet tc

" vim: filetype=vim
