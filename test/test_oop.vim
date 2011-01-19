" vim-oop's test suite

function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:sid = s:SID()

"---------------------------------------
" Object

let s:Object = oop#class#get('Object')

"---------------------------------------
" Foo < Object

let s:Foo = oop#class#new('Foo')

function! s:Foo_class_hello() dict
  return "Foo"
endfunction
call s:Foo.class_bind(s:sid, 'hello')

function! s:Foo_initialize() dict
  let self.initialized = 1
endfunction
call s:Foo.bind(s:sid, 'initialize')

function! s:Foo_hello() dict
  return "foo"
endfunction
call s:Foo.bind(s:sid, 'hello')

function! s:Foo_class_goodbye() dict
  return "Foo"
endfunction
call s:Foo.class_bind(s:sid, 'goodbye')

function! s:Foo_goodbye() dict
  return "foo"
endfunction
call s:Foo.bind(s:sid, 'goodbye')

"---------------------------------------
" Bar < Foo

let s:Bar = oop#class#new('Bar', s:Foo)

function! s:Bar_class_hello() dict
  return "Bar"
endfunction
call s:Bar.class_bind(s:sid, 'hello')

function! s:Bar_hello() dict
  return "bar"
endfunction
call s:Bar.bind(s:sid, 'hello')

"---------------------------------------
" Baz < Bar

let s:Baz = oop#class#new('Baz', 'Bar')

"-----------------------------------------------------------------------------

let tc = unittest#testcase(expand('<sfile>:p'))

function! tc.setup()
  let self.foo = s:Foo.new()
  let self.bar = s:Bar.new()
endfunction

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

function! tc.superclass_of_Object_should_be_empty()
  call assert#true(empty(s:Object.super))
endfunction

function! tc.superclass_of_Foo_should_be_Object()
  call assert#is(s:Object, s:Foo.super)
endfunction

function! tc.superclass_of_Bar_should_be_Foo()
  call assert#is(s:Foo, s:Bar.super)
endfunction

function! tc.class_method_should_be_defined()
  call assert#equal("Foo", s:Foo.hello())
  call assert#equal("Bar", s:Bar.hello())
endfunction

function! tc.class_method_should_be_inherited()
  call assert#equal("Foo", s:Bar.goodbye())
endfunction

function! tc.instance_method_should_be_defined()
  call assert#equal("foo", self.foo.hello())
  call assert#equal("bar", self.bar.hello())
endfunction

function! tc.instance_method_should_be_inherited()
  call assert#equal("foo", self.bar.goodbye())
endfunction

function! tc.foo_should_be_initialized()
  call assert#true(has_key(self.foo, 'initialized'))
endfunction

function! tc.foo_should_be_an_Object()
  call assert#true(self.foo.is_a(s:Object))
endfunction

function! tc.foo_should_be_Foo()
  call assert#true(self.foo.is_a(s:Foo))
endfunction

function! tc.foo_should_not_be_Bar()
  call assert#false(self.foo.is_a(s:Bar))
endfunction

function! tc.Class_name_should_be_class_name()
  call assert#equal('Object', s:Object.name)
  call assert#equal('Foo', s:Foo.name)
endfunction

function! tc.Class_object_id_should_be_unique_Number()
  call assert#is_Number(s:Object.object_id)
  call assert#is_Number(s:Foo.object_id)
  call assert#not_equal(s:Object.object_id, s:Foo.object_id)
endfunction

function! tc.Class_to_s_should_return_string_rep()
  call assert#equal('<Class:Object>', s:Object.to_s())
  call assert#equal('<Class:Foo>', s:Foo.to_s())

  call self.puts()
  call self.puts(s:Object.to_s())
  call self.puts(s:Foo.to_s())
endfunction

function! tc.Object_object_id_should_be_unique_Number()
  call assert#is_Number(self.foo.object_id)
  call assert#is_Number(self.bar.object_id)
  call assert#not_equal(self.foo.object_id, self.bar.object_id)
endfunction

function! tc.Object_to_s_should_return_string_rep()
  call assert#match('<Foo:0x\x\{8}>', self.foo.to_s())
  call assert#match('<Bar:0x\x\{8}>', self.bar.to_s())

  call self.puts()
  call self.puts(self.foo.to_s())
  call self.puts(self.bar.to_s())
endfunction

unlet tc

" vim: filetype=vim
