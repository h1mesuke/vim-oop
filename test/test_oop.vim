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

"---------------------------------------
" Baz < Bar

let s:Baz = oop#class#new('Baz', 'Bar')
let tc.Baz = s:Baz

function! s:Baz_class_hello_super() dict
  return "Baz < " . self.super('hello_super')
endfunction
call s:Baz.class_bind(s:SID, 'hello_super')

function! s:Baz_class_hello_no_super() dict
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
" Tests

function! tc.setup()
  let self.foo = s:Foo.new()
  let self.bar = s:Bar.new()
  let self.baz = s:Baz.new()
endfunction

"---------------------------------------
" OOP

" oop#is_class()
function! tc.test_oop_is_class()
  call assert#true(oop#is_class(s:Object))
  call assert#true(oop#is_class(s:Foo))
  call assert#false(oop#is_class(self.foo))
  call assert#false(oop#is_class({}))
  call assert#false(oop#is_class(""))
endfunction

" oop#is_instance()
function! tc.test_oop_is_instance()
  call assert#false(oop#is_instance(s:Object))
  call assert#false(oop#is_instance(s:Foo))
  call assert#true(oop#is_instance(self.foo))
  call assert#false(oop#is_instance({}))
  call assert#false(oop#is_instance(""))
endfunction

" oop#is_object()
function! tc.test_oop_is_object()
  call assert#true(oop#is_object(s:Object))
  call assert#true(oop#is_object(s:Foo))
  call assert#true(oop#is_object(self.foo))
  call assert#false(oop#is_object({}))
  call assert#false(oop#is_object(""))
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

" Class#is_a()
function! tc.Object_should_be_Class()
  call assert#true(s:Object.is_a(oop#class#get('Class')))
endfunction

function! tc.Foo_should_be_Class()
  call assert#true(s:Foo.is_a(oop#class#get('Class')))
endfunction

function! tc.Class_is_a_should_raise_if_no_class_given()
  call assert#raise('^oop: ', 'call unittest#testcase().Foo.is_a({})')
  call assert#raise('^oop: ', 'call unittest#testcase().Foo.is_a("")')
endfunction

" Class#name
function! tc.Class_name_should_be_class_name()
  call assert#equal('Object', s:Object.name)
  call assert#equal('Foo', s:Foo.name)
endfunction

" Class#object_id
function! tc.Class_object_id_should_be_unique_Number()
  call assert#is_Number(s:Object.object_id)
  call assert#is_Number(s:Foo.object_id)
  call assert#not_equal(s:Object.object_id, s:Foo.object_id)
endfunction

" Class#super()
function! tc.Class_super_should_call_super_impl()
  call assert#equal('Bar < Foo',       s:Bar.hello_super())
  call assert#equal('Baz < Bar < Foo', s:Baz.hello_super())
endfunction

function! tc.Class_super_should_raise_if_not_method()
  call assert#raise('^oop: ', 'call unittest#testcase().Baz.super("object_id")')
endfunction

function! tc.Class_super_should_raise_if_no_super_impl()
  call assert#raise('^oop: ', 'call unittest#testcase().Baz.hello_no_super()')
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

" Class#to_s()
function! tc.Class_to_s_should_return_string_rep()
  call assert#equal('<Class:Object>', s:Object.to_s())
  call assert#equal('<Class:Foo>', s:Foo.to_s())

  call self.puts()
  call self.puts(s:Object.to_s())
  call self.puts(s:Foo.to_s())
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
  call assert#true(self.foo.is_a('Object'))
endfunction

function! tc.foo_should_be_Foo()
  call assert#true(self.foo.is_a(s:Foo))
  call assert#true(self.foo.is_a('Foo'))
endfunction

function! tc.foo_should_not_be_Bar()
  call assert#false(self.foo.is_a(s:Bar))
  call assert#false(self.foo.is_a('Bar'))
endfunction

function! tc.Object_is_a_should_raise_if_no_class_given()
  call assert#raise('^oop: ', 'call unittest#testcase().foo.is_a({})')
  call assert#raise('^oop: ', 'call unittest#testcase().foo.is_a("")')
endfunction

" Object#object_id
function! tc.Object_object_id_should_be_unique_Number()
  call assert#is_Number(self.foo.object_id)
  call assert#is_Number(self.bar.object_id)
  call assert#not_equal(self.foo.object_id, self.bar.object_id)
endfunction

" Object#super()
function! tc.Object_super_should_call_super_impl()
  call assert#equal('bar < foo',       self.bar.hello_super())
  call assert#equal('baz < bar < foo', self.baz.hello_super())
endfunction

function! tc.Object_super_should_raise_if_not_method()
  call assert#raise('^oop: ', 'call unittest#testcase().baz.super("object_id")')
endfunction

function! tc.Object_super_should_raise_if_no_super_impl()
  call assert#raise('^oop: ', 'call unittest#testcase().baz.hello_no_super()')
endfunction

" Object#to_s()
function! tc.Object_to_s_should_return_string_rep()
  call assert#match('<Foo:0x\x\{8}>', self.foo.to_s())
  call assert#match('<Bar:0x\x\{8}>', self.bar.to_s())

  call self.puts()
  call self.puts(self.foo.to_s())
  call self.puts(self.bar.to_s())
endfunction

unlet tc

" vim: filetype=vim
