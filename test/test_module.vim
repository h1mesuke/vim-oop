" vim-oop's test suite

let s:save_cpo = &cpo
set cpo&vim

"-----------------------------------------------------------------------------

" h1mesuke/vim-unittest - GitHub
" https://github.com/h1mesuke/vim-unittest
"
let s:tc = unittest#testcase#new("Module")

function! s:tc.SETUP()
  runtime autoload/oop.vim
  runtime autoload/oop/module.vim

  " module Fizz
  function! s:define()
    let s:Fizz = oop#module#new('Fizz')
  endfunction
  call s:define()

  function! s:Fizz_hello() dict
    return "Fizz's hello"
  endfunction
  call s:Fizz.function('hello')
  call s:Fizz.alias('hi', 'hello')

  function! s:Fizz_hello_cn() dict
    return "Fizz's nihao"
  endfunction
  call s:Fizz.function('hello_cn', 'nihao')
endfunction

" {Module}.function()
function! s:tc.Module_function___it_should_bind_Funcref_as_module_function()
  call self.assert_is_Funcref(s:Fizz.hello)
  call self.assert_equal("Fizz's hello", s:Fizz.hello())
endfunction

function! s:tc.Module_function___it_should_bind_Funcref_as_module_function_with_given_name()
  call self.assert_is_Funcref(s:Fizz.nihao)
  call self.assert_equal("Fizz's nihao", s:Fizz.nihao())

  call self.assert_not(has_key(s:Fizz, 'hello_cn'))
endfunction

" {Module}.alias()
function! s:tc.Module_alias___it_should_define_alias_of_module_function()
  call self.assert_equal(s:Fizz.hello, s:Fizz.hi)
endfunction

" oop#is_object()
function! s:tc.oop_is_object___Fizz_should_be_Object()
  call self.assert(oop#is_object(s:Fizz))
endfunction

" oop#is_module()
function! s:tc.oop_is_module___Fizz_should_be_Module()
  call self.assert(oop#is_module(s:Fizz))
endfunction

unlet s:tc

let &cpo = s:save_cpo
unlet s:save_cpo
