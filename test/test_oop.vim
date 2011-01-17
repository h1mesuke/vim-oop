" vim-oop's test suite

let s:Object = oop#object#class()

let s:Foo = oop#class#new()

function! s:Foo.hello()
  return "Foo"
endfunction

function! s:Foo.prototype.initialize()
  let self.initialized = 1
endfunction

function! s:Foo.prototype.hello()
  return "foo"
endfunction

function! s:Foo.goodbye()
  return "Foo"
endfunction

function! s:Foo.prototype.goodbye()
  return "foo"
endfunction

let s:Bar = oop#class#new(s:Foo)

function! s:Bar.hello()
  return "Bar"
endfunction

function! s:Bar.prototype.hello()
  return "bar"
endfunction

"-----------------------------------------------------------------------------

let tc = unittest#testcase(expand('<sfile>:p'))

function! tc.setup()
  let self.foo = s:Foo.new()
  let self.bar = s:Bar.new()
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

function! tc.class_define_should_define_class_method()
  call assert#equal("Foo", s:Foo.hello())
  call assert#equal("Bar", s:Bar.hello())
endfunction

function! tc.class_method_should_be_inherited()
  call assert#equal("Foo", s:Bar.goodbye())
endfunction

function! tc.define_should_define_instance_method()
  call assert#equal("foo", self.foo.hello())
  call assert#equal("bar", self.bar.hello())
endfunction

function! tc.instance_method_should_be_inherited()
  call assert#equal("foo", self.bar.goodbye())
endfunction

function! tc.foo_should_be_initialized()
  call assert#true(has_key(self.foo, 'initialized'))
endfunction

function! tc.foo_is_an_Object()
  call assert#true(self.foo.is_a(s:Object))
endfunction

function! tc.foo_is_a_Foo()
  call assert#true(self.foo.is_a(s:Foo))
endfunction

function! tc.foo_is_not_a_Bar()
  call assert#false(self.foo.is_a(s:Bar))
endfunction

unlet tc

" vim: filetype=vim
