" vim-oop's test suite
"
" Test case of assertions
"
"-----------------------------------------------------------------------------
" Expected results:
"
"   {T} tests, {A} assertions, {A/2} failures, 0 errors
"
" NOTE: The tests in this file are written to test assertions themselves, so
" not only successes but also failures are expected as the results.
"
"-----------------------------------------------------------------------------

" h1mesuke/vim-unittest - GitHub
" https://github.com/h1mesuke/vim-unittest
"
let s:tc = unittest#testcase#new("Assertions")

function! s:tc.SETUP()
  runtime autoload/oop.vim
  runtime autoload/oop/assertions.vim
  call self.extend(oop#assertions#export())

  function! s:define()
    " class Foo
    let s:Foo = oop#class#new('Foo')
    " class Bar < Foo
    let s:Bar = oop#class#new('Bar', s:Foo)
    " module Fizz
    let s:Fizz = oop#module#new('Fizz')
  endfunction
  call s:define()
endfunction

function! s:tc.setup()
  let self.foo = s:Foo.new()
  let self.bar = s:Bar.new()
endfunction

function! s:tc.test_assert_is_Object()
  call self.assert_is_Object(s:Foo)
  call self.assert_is_Object({})
endfunction

function! s:tc.test_assert_is_Class()
  call self.assert_is_Class(s:Foo)
  call self.assert_is_Class(self.foo)
endfunction

function! s:tc.test_assert_is_Instance()
  call self.assert_is_Instance(self.foo)
  call self.assert_is_Instance(s:Foo)
endfunction

function! s:tc.test_assert_is_Module()
  call self.assert_is_Module(s:Fizz)
  call self.assert_is_Module({})
endfunction

function! s:tc.test_assert_is_kind_of()
  call self.assert_is_kind_of(s:Foo, self.bar)
  call self.assert_is_kind_of(s:Bar, self.foo)
endfunction

function! s:tc.test_assert_is_instance_of()
  call self.assert_is_instance_of(s:Foo, self.foo)
  call self.assert_is_instance_of(s:Bar, self.foo)
endfunction

unlet s:tc
