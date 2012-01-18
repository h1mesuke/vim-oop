" vim-oop's test suite
"
" Test case of assertions
"
"-----------------------------------------------------------------------------
" Expected results:
"
"   {T} tests, {A} assertions, {A/2} failures, 1 errors
"
" NOTE: The tests in this file are written to test assertions themselves, so
" not only successes but also failures are expected as the results.
"
"-----------------------------------------------------------------------------

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

" h1mesuke/vim-unittest - GitHub
" https://github.com/h1mesuke/vim-unittest
"
let s:tc = unittest#testcase#new("Assertions")
call s:tc.extend(oop#assertions#module())

function! s:tc.SETUP()
  " Clear the namespace.
  call filter(oop#__namespace__(), 0)

  " class Foo
  let s:Foo = oop#class#new('Foo', s:SID)
  " class Bar < Foo
  let s:Bar = oop#class#new('Bar', s:SID, s:Foo)
  " module Fizz
  let s:Fizz = oop#module#new('Fizz', s:SID)
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
