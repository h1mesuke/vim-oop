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

let s:tc = unittest#testcase#new('test_module')

" Module#function()
function! s:tc.Module_function_should_bind_Funcref_as_module_function()
  call self.assert_is_Funcref(s:Fizz.hello)
  call self.assert_equal("Fizz's hello", s:Fizz.hello())
endfunction

function! s:tc.Module_function_should_bind_Funcref_as_module_function_with_given_name()
  call self.assert_is_Funcref(s:Fizz.nihao)
  call self.assert_equal("Fizz's nihao", s:Fizz.nihao())

  call self.assert_not(has_key(s:Fizz, 'hello_cn'))
endfunction

" Module#alias()
function! s:tc.Module_alias_should_define_alias_of_module_function()
  call self.assert_equal(s:Fizz.hello, s:Fizz.hi)
endfunction

" oop#is_object()
function! s:tc.Fizz_should_be_Object()
  call self.assert(oop#is_object(s:Fizz))
endfunction

" oop#is_module()
function! s:tc.Fizz_should_be_Module()
  call self.assert(oop#is_module(s:Fizz))
endfunction

" oop#string()
function! s:tc.test_oop_string()
  call self.assert_equal('<Module: Fizz>', oop#string(s:Fizz))
endfunction

unlet s:tc

" vim: filetype=vim
