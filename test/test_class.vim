" vim-oop's test suite

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

"-----------------------------------------------------------------------------
" Classes

"---------------------------------------
" Foo

let s:Foo = oop#class#new('Foo', s:SID)

function! s:Foo_initialize() dict
  let self.initialized = 1
endfunction
call s:Foo.method('initialize')

function! s:Foo_hello() dict
  return "Foo"
endfunction
call s:Foo.class_method('hello')
call s:Foo.method('hello')

call s:Foo.class_alias('hi', 'hello')
call s:Foo.alias('hi', 'hello')

function! s:Foo_ciao() dict
  return "Foo"
endfunction
call s:Foo.class_method('ciao')
call s:Foo.method('ciao')

function! s:Foo_hello_cn() dict
  return "Foo's nihao"
endfunction
call s:Foo.class_method('hello_cn', 'nihao')
call s:Foo.method('hello_cn', 'nihao')

"---------------------------------------
" Bar < Foo

let s:Bar = oop#class#new('Bar', s:SID, s:Foo)

function! s:Bar_hello() dict
  return "Bar < " . s:Bar.super('hello', self)
endfunction
call s:Bar.class_method('hello')
call s:Bar.method('hello')

"---------------------------------------
" Baz < Bar

let s:Baz = oop#class#new('Baz', s:SID, s:Bar)

function! s:Baz_hello() dict
  return "Baz < " . s:Baz.super('hello', self)
endfunction
call s:Baz.class_method('hello')
call s:Baz.method('hello')

function! s:Baz_bonjour() dict
  return "Baz < " . s:Baz.super('bonjour', self)
endfunction
call s:Baz.class_method('bonjour')
call s:Baz.method('bonjour')

"-----------------------------------------------------------------------------
" Module

"---------------------------------------
" Fizz

let s:Fizz = oop#module#new('Fizz', s:SID)

function! s:Fizz_is_extended() dict
endfunction
call s:Fizz.function('is_extended')

"-----------------------------------------------------------------------------
" Tests

" h1mesuke/vim-unittest - GitHub
" https://github.com/h1mesuke/vim-unittest

let tc = unittest#testcase#new('test_class')

let tc.Foo = s:Foo
let tc.Bar = s:Bar
let tc.Baz = s:Baz

function! tc.setup()
  let self.foo = s:Foo.new()
  let self.bar = s:Bar.new()
  let self.baz = s:Baz.new()
endfunction

" oop#class#new()
function! tc.class_methods_should_be_inherited()
  call assert#equal("Foo", s:Bar.ciao())
  call assert#equal("Foo", s:Baz.ciao())
endfunction

function! tc.instance_methods_should_be_inherited()
  call assert#equal("Foo", self.bar.ciao())
  call assert#equal("Foo", self.baz.ciao())
endfunction

" Class#extend()
function! tc.Class_extend_should_add_module_funcs_as_class_methods()
  call assert#not(has_key(s:Foo, 'is_extended'))

  call s:Foo.extend(s:Fizz)

  call assert#_(has_key(s:Foo, 'is_extended'))
endfunction

" Class#include()
function! tc.Class_include_should_add_module_funcs_as_instance_methods()
  let foo = s:Foo.new()
  call assert#not(has_key(foo, 'is_extended'))

  call s:Foo.include(s:Fizz)

  let foo = s:Foo.new()
  call assert#_(has_key(foo, 'is_extended'))
endfunction

" Class#ancestors()
function! tc.Class_ancestors_should_return_List_of_ancestors()
  call assert#equal(s:Foo.ancestors(),  [])
  call assert#equal(s:Foo.ancestors(1), [s:Foo])

  call assert#equal(s:Baz.ancestors(),  [s:Bar, s:Foo])
  call assert#equal(s:Baz.ancestors(1), [s:Baz, s:Bar, s:Foo])
endfunction

" Class#is_descendant_of()
function! tc.Bar_should_be_descendant_of_Foo()
  call assert#_(s:Bar.is_descendant_of(s:Foo))
endfunction

function! tc.Bar_should_not_be_descendant_of_Bar()
  call assert#not(s:Bar.is_descendant_of(s:Baz))
endfunction

" Class#class_method()
function! tc.Class_class_method_should_bind_Funcref_as_class_method()
  call assert#is_Funcref(s:Foo.hello)
  call assert#equal("Foo", s:Foo.hello())
endfunction

function! tc.Class_class_method_should_bind_Funcref_as_class_method_with_given_name()
  call assert#is_Funcref(s:Foo.nihao)
  call assert#equal("Foo's nihao", s:Foo.nihao())

  call assert#not(has_key(s:Foo, 'hello_cn'))
endfunction

" Class#method()
function! tc.Class_method_should_bind_Funcref_as_instance_method()
  call assert#is_Funcref(self.foo.hello)
  call assert#equal("Foo", self.foo.hello())
endfunction

function! tc.Class_method_should_bind_Funcref_as_instance_method_with_given_name()
  call assert#is_Funcref(self.foo.nihao)
  call assert#equal("Foo's nihao", self.foo.nihao())

  call assert#not(has_key(self.foo, 'hello_cn'))
endfunction

" Class#class_alias()
function! tc.Class_class_alias_should_define_alias_of_class_method()
  call assert#equal(s:Foo.hello, s:Foo.hi)
endfunction

" Class#alias()
function! tc.Class_alias_should_define_alias_of_instance_method()
  call assert#equal(self.foo.hello, self.foo.hi)
endfunction

" Class#super()
function! tc.Class_super_should_call_super_impl()
  call assert#equal('Bar < Foo',       s:Bar.hello())
  call assert#equal('Baz < Bar < Foo', s:Baz.hello())

  call assert#equal('Bar < Foo',       self.bar.hello())
  call assert#equal('Baz < Bar < Foo', self.baz.hello())
endfunction

function! tc.Class_super_should_raise_if_not_method()
  call assert#raise('^vim-oop: ', '
        \ call unittest#testcase().Baz.super("__superclass__", unittest#testcase().Baz)
        \ ')
  call assert#raise('^vim-oop: ', '
        \ call unittest#testcase().Baz.super("__class__", unittest#testcase().baz)
        \ ')
endfunction

function! tc.Class_super_should_raise_if_no_super_impl()
  call assert#raise('^vim-oop: ', '
        \ call unittest#testcase().Baz.super("bonjour", unittest#testcase().Baz)
        \ ')
  call assert#raise('^vim-oop: ', '
        \ call unittest#testcase().Baz.super("bonjour", unittest#testcase().baz)
        \ ')
endfunction

" Object#initialize()
function! tc.instance_should_be_initialized()
  call assert#_(has_key(self.foo, 'initialized'))
endfunction

" Object#is_a()
function! tc.foo_should_be_Foo()
  call assert#_(self.foo.is_a(s:Foo))
endfunction

function! tc.foo_should_not_be_Bar()
  call assert#not(self.foo.is_a(s:Bar))
endfunction

" oop#is_object()
function! tc.Foo_should_be_Object()
  call assert#_(oop#is_object(s:Foo))
endfunction

function! tc.foo_should_be_Object()
  call assert#_(oop#is_object(self.foo))
endfunction

" oop#is_class()
function! tc.Foo_should_be_Class()
  call assert#_(oop#is_class(s:Foo))
endfunction

function! tc.foo_should_not_be_Class()
  call assert#not(oop#is_class(self.foo))
endfunction

" oop#is_instance()
function! tc.Foo_should_not_be_Instance()
  call assert#not(oop#is_instance(s:Foo))
endfunction

function! tc.foo_should_be_Instance()
  call assert#_(oop#is_instance(self.foo))
endfunction

" oop#string()
function! tc.test_oop_string()
  call self.puts()
  call self.puts(oop#string(s:Foo))
  call self.puts(oop#string(self.foo))
endfunction

unlet tc

" vim: filetype=vim
