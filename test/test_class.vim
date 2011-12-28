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
  return "Foo's hello"
endfunction
call s:Foo.class_method('hello')
call s:Foo.method('hello')

call s:Foo.class_alias('hi', 'hello')
call s:Foo.alias('hi', 'hello')

function! s:Foo_ciao() dict
  return "Foo's ciao"
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
  return "Bar's hello < " . s:Bar.super('hello', [], self)
endfunction
call s:Bar.class_method('hello')
call s:Bar.method('hello')

"---------------------------------------
" Baz < Bar

let s:Baz = oop#class#new('Baz', s:SID, s:Bar)

function! s:Baz_hello() dict
  return "Baz's hello < " . s:Baz.super('hello', [], self)
endfunction
call s:Baz.class_method('hello')
call s:Baz.method('hello')

function! s:Baz_bonjour() dict
  return "Baz's bonjour < " . s:Baz.super('bonjour', [], self)
endfunction
call s:Baz.class_method('bonjour')
call s:Baz.method('bonjour')

"-----------------------------------------------------------------------------
" Module

"---------------------------------------
" Fizz

let s:Fizz = oop#module#new('Fizz', s:SID)

function! s:Fizz_is_extended() dict
  return 1
endfunction
call s:Fizz.function('is_extended')

"-----------------------------------------------------------------------------
" Tests

" h1mesuke/vim-unittest - GitHub
" https://github.com/h1mesuke/vim-unittest

let s:tc = unittest#testcase#new('test_class')

let s:tc.Foo = s:Foo
let s:tc.Bar = s:Bar
let s:tc.Baz = s:Baz

function! s:tc.setup()
  let self.foo = s:Foo.new()
  let self.bar = s:Bar.new()
  let self.baz = s:Baz.new()
endfunction

" oop#class#new()
function! s:tc.class_methods_should_be_inherited()
  call self.assert_equal("Foo's ciao", s:Bar.ciao())
  call self.assert_equal("Foo's ciao", s:Baz.ciao())
endfunction

function! s:tc.instance_methods_should_be_inherited()
  call self.assert_equal("Foo's ciao", self.bar.ciao())
  call self.assert_equal("Foo's ciao", self.baz.ciao())
endfunction

" Class#extend()
function! s:tc.Class_extend_should_add_module_functions_as_class_methods()
  call self.assert_not(has_key(s:Foo, 'is_extended'))

  call s:Foo.extend(s:Fizz)

  call self.assert(has_key(s:Foo, 'is_extended'))
  call self.assert_is_Funcref(s:Foo.is_extended)
endfunction

" Class#include()
function! s:tc.Class_include_should_add_module_functions_as_instance_methods()
  let foo = s:Foo.new()
  call self.assert_not(has_key(foo, 'is_extended'))

  call s:Foo.include(s:Fizz)

  let foo = s:Foo.new()
  call self.assert(has_key(foo, 'is_extended'))
  call self.assert_is_Funcref(foo.is_extended)
endfunction

" Class#ancestors()
function! s:tc.Class_ancestors_should_return_List_of_ancestors()
  call self.assert_equal(s:Foo.ancestors(),  [])
  call self.assert_equal(s:Foo.ancestors(1), [s:Foo])

  call self.assert_equal(s:Baz.ancestors(),  [s:Bar, s:Foo])
  call self.assert_equal(s:Baz.ancestors(1), [s:Baz, s:Bar, s:Foo])
endfunction

" Class#is_descendant_of()
function! s:tc.Bar_should_be_descendant_of_Foo()
  call self.assert(s:Bar.is_descendant_of(s:Foo))
endfunction

function! s:tc.Bar_should_not_be_descendant_of_Bar()
  call self.assert_not(s:Bar.is_descendant_of(s:Baz))
endfunction

" Class#class_method()
function! s:tc.Class_class_method_should_bind_Funcref_as_class_method()
  call self.assert_is_Funcref(s:Foo.hello)
  call self.assert_equal("Foo's hello", s:Foo.hello())
endfunction

function! s:tc.Class_class_method_should_bind_Funcref_as_class_method_with_given_name()
  call self.assert_is_Funcref(s:Foo.nihao)
  call self.assert_equal("Foo's nihao", s:Foo.nihao())

  call self.assert_not(has_key(s:Foo, 'hello_cn'))
endfunction

" Class#method()
function! s:tc.Class_method_should_bind_Funcref_as_instance_method()
  call self.assert_is_Funcref(self.foo.hello)
  call self.assert_equal("Foo's hello", self.foo.hello())
endfunction

function! s:tc.Class_method_should_bind_Funcref_as_instance_method_with_given_name()
  call self.assert_is_Funcref(self.foo.nihao)
  call self.assert_equal("Foo's nihao", self.foo.nihao())

  call self.assert_not(has_key(self.foo, 'hello_cn'))
endfunction

" Class#class_alias()
function! s:tc.Class_class_alias_should_define_alias_of_class_method()
  call self.assert_equal(s:Foo.hello, s:Foo.hi)
endfunction

" Class#alias()
function! s:tc.Class_alias_should_define_alias_of_instance_method()
  call self.assert_equal(self.foo.hello, self.foo.hi)
endfunction

" Class#super()
function! s:tc.Class_super_should_call_super_impl()
  call self.assert_equal("Bar's hello < Foo's hello", s:Bar.hello())
  call self.assert_equal("Baz's hello < Bar's hello < Foo's hello", s:Baz.hello())

  call self.assert_equal("Bar's hello < Foo's hello", self.bar.hello())
  call self.assert_equal("Baz's hello < Bar's hello < Foo's hello", self.baz.hello())
endfunction

function! s:tc.Class_super_should_throw_if_not_method()
  call self.assert_throw('^vim-oop: ', '
        \ call unittest#self().Baz.super("__superclass__", [], unittest#self().Baz)
        \ ')
  call self.assert_throw('^vim-oop: ', '
        \ call unittest#self().Baz.super("__class__", [], unittest#self().baz)
        \ ')
endfunction

function! s:tc.Class_super_should_throw_if_no_super_impl()
  call self.assert_throw('^vim-oop: ', '
        \ call unittest#self().Baz.super("bonjour", [], unittest#self().Baz)
        \ ')
  call self.assert_throw('^vim-oop: ', '
        \ call unittest#self().Baz.super("bonjour", [], unittest#self().baz)
        \ ')
endfunction

" Object#initialize()
function! s:tc.instance_should_be_initialized()
  call self.assert(has_key(self.foo, 'initialized'))
endfunction

" Object#is_a()
function! s:tc.foo_should_be_Foo()
  call self.assert(self.foo.is_a(s:Foo))
endfunction

function! s:tc.foo_should_not_be_Bar()
  call self.assert_not(self.foo.is_a(s:Bar))
endfunction

" oop#is_object()
function! s:tc.Foo_should_be_Object()
  call self.assert(oop#is_object(s:Foo))
endfunction

function! s:tc.foo_should_be_Object()
  call self.assert(oop#is_object(self.foo))
endfunction

" oop#is_class()
function! s:tc.Foo_should_be_Class()
  call self.assert(oop#is_class(s:Foo))
endfunction

function! s:tc.foo_should_not_be_Class()
  call self.assert_not(oop#is_class(self.foo))
endfunction

" oop#is_instance()
function! s:tc.Foo_should_not_be_Instance()
  call self.assert_not(oop#is_instance(s:Foo))
endfunction

function! s:tc.foo_should_be_Instance()
  call self.assert(oop#is_instance(self.foo))
endfunction

" oop#string()
function! s:tc.test_oop_string()
  call self.assert_equal('<Class: Foo>', oop#string(s:Foo))
  call self.assert_equal("{'initialized': 1, '__class__': '<Class: Foo>'}", oop#string(self.foo))

  call self.assert_equal(string(10), oop#string(10))
  call self.assert_equal(string("String"), oop#string("String"))
  call self.assert_equal(string([1, 2, 3]), oop#string([1, 2, 3]))
  call self.assert_equal(string({'a': 1, 'b': 2}), oop#string({'a': 1, 'b': 2}))
endfunction

unlet s:tc

" vim: filetype=vim
