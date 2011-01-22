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
" OOP

" oop#is_class()
function! tc.test_oop_is_class()
  call assert#true(oop#is_class(s:Object))
  call assert#true(oop#is_class(s:Foo))
  call assert#false(oop#is_class(self.foo))
  call assert#false(oop#is_class({}))
  call assert#false(oop#is_class(""))
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

" Class#class_alias()
function! tc.Class_class_alias_should_define_alias_of_class_method()
  call assert#equal(s:Foo.hello, s:Foo.hello_alias)
endfunction

" Class#class_bind()
function! tc.Class_class_bind_should_bind_Funcref_as_class_method()
  call assert#equal("Foo", s:Foo.hello())
  call assert#equal("Bar", s:Bar.hello())
endfunction

" Class#alias()
function! tc.Class_alias_should_define_alias_of_instance_method()
  call assert#equal(self.foo.hello, self.foo.hello_alias)
endfunction

" Class#bind()
function! tc.Class_bind_should_bind_Funcref_as_instance_method()
  call assert#equal("foo", self.foo.hello())
  call assert#equal("bar", self.bar.hello())
endfunction

" Class#export()
function! tc.Class_export_should_export_instance_method_as_class_method()
  call assert#equal(s:Foo.hello_export, self.foo.hello_export)
endfunction

" Class#is_a()
function! tc.Class_is_a_should_be_alias_of_Class_is_kind_of()
  call assert#equal(s:Foo.is_kind_of, s:Foo.is_a)
endfunction

" Class#is_kind_of()
function! tc.Object_should_be_Class()
  call assert#true(s:Object.is_kind_of(oop#class#get('Class')))
endfunction

function! tc.Foo_should_be_Class()
  call assert#true(s:Foo.is_kind_of(oop#class#get('Class')))
endfunction

function! tc.Foo_should_be_Object()
  call assert#true(s:Foo.is_kind_of(s:Object))
endfunction

function! tc.Foo_should_not_be_Bar()
  call assert#false(s:Foo.is_kind_of(s:Bar))
endfunction

function! tc.Class_is_kind_of_should_raise_if_no_class_given()
  call assert#raise('^oop: ', 'call unittest#testcase().Foo.is_kind_of({})')
  call assert#raise('^oop: ', 'call unittest#testcase().Foo.is_kind_of("")')
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
function! tc.instance_should_be_initialized()
  call assert#true(has_key(self.foo, 'initialized'))
endfunction

" Object#is_a()
function! tc.Object_is_a_should_be_alias_of_Object_is_kind_of()
  call assert#equal(self.foo.is_kind_of, self.foo.is_a)
endfunction

" Object#is_kind_of()
function! tc.foo_should_be_kind_of_Object()
  call assert#true(self.foo.is_kind_of(s:Object))
  call assert#true(self.foo.is_kind_of('Object'))
endfunction

function! tc.foo_should_be_kind_of_Foo()
  call assert#true(self.foo.is_kind_of(s:Foo))
  call assert#true(self.foo.is_kind_of('Foo'))
endfunction

function! tc.foo_should_not_be_kind_of_Bar()
  call assert#false(self.foo.is_kind_of(s:Bar))
  call assert#false(self.foo.is_kind_of('Bar'))
endfunction

function! tc.Object_is_kind_of_should_raise_if_no_class_given()
  call assert#raise('^oop: ', 'call unittest#testcase().foo.is_kind_of({})')
  call assert#raise('^oop: ', 'call unittest#testcase().foo.is_kind_of("")')
endfunction

unlet tc

" vim: filetype=vim
