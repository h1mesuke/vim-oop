" vim-oop's test suite

let tc = unittest#testcase#new('test_oop')

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()

"-----------------------------------------------------------------------------
" Classes

"---------------------------------------
" Object

let s:Object = oop#class#get('Object')
let tc.Object = s:Object

"---------------------------------------
" Foo < Object

let s:Foo = oop#class#new('Foo')
let tc.Foo = s:Foo

function! s:Foo_class_hello() dict
  return "Foo"
endfunction
call s:Foo.class_bind(s:SID, 'hello')

function! s:Foo_initialize() dict
  let self.initialized = 1
endfunction
call s:Foo.bind(s:SID, 'initialize')

function! s:Foo_hello() dict
  return "foo"
endfunction
call s:Foo.bind(s:SID, 'hello')

function! s:Foo_class_goodbye() dict
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
let tc.Bar = s:Bar

function! s:Bar_class_hello() dict
  return "Bar"
endfunction
call s:Bar.class_bind(s:SID, 'hello')

function! s:Bar_class_hello_super() dict
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

"-----------------------------------------------------------------------------
" Tests

function! tc.setup()
  let self.foo = s:Foo.new()
  let self.bar = s:Bar.new()
endfunction

"---------------------------------------
" Class

" Class.new()
function! tc.Object_class_should_be_defined()
  call assert#true(oop#class#is_defined('Object'))
endfunction

function! tc.Foo_class_should_be_defined()
  call assert#true(oop#class#is_defined('Foo'))
endfunction

function! tc.Object_class_should_be_registered_to_class_table()
  call assert#is(s:Object, oop#class#get('Object'))
endfunction

function! tc.Foo_class_should_be_registered_to_class_table()
  call assert#is(s:Foo, oop#class#get('Foo'))
endfunction

function! tc.class_method_should_be_inherited()
  call assert#equal("Foo", s:Bar.goodbye())
endfunction

function! tc.instance_method_should_be_inherited()
  call assert#equal("foo", self.bar.goodbye())
endfunction

" Class#class_define()
function! tc.class_method_should_be_defined()
  call assert#equal("Foo", s:Foo.hello())
  call assert#equal("Bar", s:Bar.hello())
endfunction

" Class#define()
function! tc.instance_method_should_be_defined()
  call assert#equal("foo", self.foo.hello())
  call assert#equal("bar", self.bar.hello())
endfunction

" Class#name
function! tc.Class_name_should_be_class_name()
  call assert#equal('Object', s:Object.name)
  call assert#equal('Foo', s:Foo.name)
endfunction

" Class#superclass
function! tc.superclass_of_Object_should_be_empty()
  call assert#true(empty(s:Object.superclass))
endfunction

function! tc.superclass_of_Foo_should_be_Object()
  call assert#is(s:Object, s:Foo.superclass)
endfunction

function! tc.superclass_of_Bar_should_be_Foo()
  call assert#is(s:Foo, s:Bar.superclass)
endfunction

"---------------------------------------
" Object

" Object#initialize()
function! tc.foo_should_be_initialized()
  call assert#true(has_key(self.foo, 'initialized'))
endfunction

" Object#is_a()
function! tc.foo_should_be_Object()
  call assert#true(self.foo.is_a(s:Object))
endfunction

function! tc.foo_should_be_Foo()
  call assert#true(self.foo.is_a(s:Foo))
endfunction

function! tc.foo_should_not_be_Bar()
  call assert#false(self.foo.is_a(s:Bar))
endfunction

unlet tc

" vim: filetype=vim
