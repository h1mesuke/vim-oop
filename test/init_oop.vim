" vim-oop's test suite

if exists('s:SID')
  finish
endif

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()

"-----------------------------------------------------------------------------
" Classes

"---------------------------------------
" Foo < Object

let s:Foo = oop#class#new('Foo')

function! s:class_Foo_hello() dict
  return "Foo"
endfunction
call s:Foo.class_bind(s:SID, 'hello')
call s:Foo.class_alias('hello_alias', 'hello')

function! s:Foo_initialize() dict
  let self.initialized = 1
endfunction
call s:Foo.bind(s:SID, 'initialize')

function! s:Foo_hello() dict
  return "foo"
endfunction
call s:Foo.bind(s:SID, 'hello')
call s:Foo.alias('hello_alias', 'hello')

call s:Foo.alias('hello_export', 'hello')
call s:Foo.export('hello_export')

function! s:class_Foo_goodbye() dict
  return "Foo"
endfunction
call s:Foo.class_bind(s:SID, 'goodbye')

function! s:Foo_goodbye() dict
  return "foo"
endfunction
call s:Foo.bind(s:SID, 'goodbye')

"---------------------------------------
" Bar < Foo

let s:Bar = oop#class#new('Bar', s:Foo)

function! s:class_Bar_hello() dict
  return "Bar"
endfunction
call s:Bar.class_bind(s:SID, 'hello')

function! s:class_Bar_hello_super() dict
  return "Bar < " . self.super('hello')
endfunction
call s:Bar.class_bind(s:SID, 'hello_super')

function! s:Bar_hello() dict
  return "bar"
endfunction
call s:Bar.bind(s:SID, 'hello')

function! s:Bar_hello_super() dict
  return "bar < " . self.super('hello')
endfunction
call s:Bar.bind(s:SID, 'hello_super')

"---------------------------------------
" Baz < Bar

let s:Baz = oop#class#new('Baz', 'Bar')

function! s:class_Baz_hello_super() dict
  return "Baz < " . self.super('hello_super')
endfunction
call s:Baz.class_bind(s:SID, 'hello_super')

function! s:class_Baz_hello_no_super() dict
  return "Baz < " . self.super('hello_no_super')
endfunction
call s:Baz.class_bind(s:SID, 'hello_no_super')

function! s:Baz_hello_super() dict
  return "baz < " . self.super('hello_super')
endfunction
call s:Baz.bind(s:SID, 'hello_super')

function! s:Baz_hello_no_super() dict
  return "baz < " . self.super('hello_no_super')
endfunction
call s:Baz.bind(s:SID, 'hello_no_super')

"-----------------------------------------------------------------------------
" Modules

"---------------------------------------
" Fizz

let s:Fizz = oop#module#new('Fizz')

function! s:Fizz_hello() dict
  return "Fizz"
endfunction
call s:Fizz.bind(s:SID, 'hello')
call s:Fizz.alias('hello_alias', 'hello')

"---------------------------------------
" Buzz

let s:Buzz = oop#module#new('Buzz')

function! s:Buzz_hello() dict
  return "Buzz"
endfunction
call s:Buzz.bind(s:SID, 'hello')

" vim: filetype=vim
