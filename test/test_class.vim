" vim-oop's test suite

let s:save_cpo = &cpo
set cpo&vim

"-----------------------------------------------------------------------------

" h1mesuke/vim-unittest - GitHub
" https://github.com/h1mesuke/vim-unittest
"
let s:tc = unittest#testcase#new("Class and Instances")

function! s:tc.SETUP()
  runtime autoload/oop.vim
  runtime autoload/oop/class.vim
  runtime autoload/oop/module.vim

  " class Foo
  function! s:define()
    let s:Foo = oop#class#new('Foo')
  endfunction
  call s:define()

  function! s:Foo_initialize() dict
    let self.initialized = get(self, 'initialized', 0) + 1
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

  " class Bar < Foo
  function! s:define()
    let s:Bar = oop#class#new('Bar', s:Foo)
  endfunction
  call s:define()

  function! s:Bar_initialize() dict
    call s:Bar.super('initialize', [], self)
  endfunction
  call s:Bar.method('initialize')

  function! s:Bar_hello() dict
    return "Bar's hello < " . s:Bar.super('hello', [], self)
  endfunction
  call s:Bar.class_method('hello')
  call s:Bar.method('hello')

  " class Baz < Bar
  function! s:define()
    let s:Baz = oop#class#new('Baz', s:Bar)
  endfunction
  call s:define()

  function! s:Baz_initialize() dict
    call s:Baz.super('initialize', [], self)
  endfunction
  call s:Baz.method('initialize')

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

  " class XFoo
  function! s:define()
    let s:XFoo = oop#class#xnew('XFoo')
  endfunction
  call s:define()

  function! s:XFoo_initialize() dict
    let self.initialized = get(self, 'initialized', 0) + 1
  endfunction
  call s:XFoo.method('initialize')

  function! s:XFoo_hello() dict
    return "XFoo's hello"
  endfunction
  call s:XFoo.method('hello')

  " module Buzz
  function! s:define()
    let s:Buzz = oop#module#new('Buzz')
  endfunction
  call s:define()

  function! s:Buzz_is_extended() dict
    return 1
  endfunction
  call s:Buzz.function('is_extended')
endfunction

function! s:tc.setup()
  let self.Foo  = s:Foo | let self.foo  = s:Foo.new()
  let self.Bar  = s:Bar | let self.bar  = s:Bar.new()
  let self.Baz  = s:Baz | let self.baz  = s:Baz.new()
  let self.Buzz = s:Buzz
endfunction

" oop#class#new()
function! s:tc.oop_class_new___it_should_inherit_class_methods_from_superclasses()
  call self.assert_equal("Foo's ciao", s:Bar.ciao())
  call self.assert_equal("Foo's ciao", s:Baz.ciao())
endfunction

function! s:tc.oop_class_new___it_should_inherit_instance_methods_from_superclasses()
  call self.assert_equal("Foo's ciao", self.bar.ciao())
  call self.assert_equal("Foo's ciao", self.baz.ciao())
endfunction

function! s:tc.oop_class_new___it_should_throw_TypeError_when_superclass_is_not_class()
  call self.assert_throw('^vim-oop: TypeError: ', 'call self.define_class_with_type_error()')
endfunction
function! s:tc.define_class_with_type_error()
  function! s:define()
    call oop#class#new('Boo', 10)
  endfunction
  call s:define()
endfunction

" {Class}.extend()
function! s:tc.setup_Class_extend()
  let self.Foo = deepcopy(s:Foo)
  call self.Foo.extend(s:Buzz)
endfunction

function! s:tc.Class_extend___it_should_include_module_functions_as_class_methods()
  call self.assert_has_key('is_extended', self.Foo)
  call self.assert_is_Funcref(self.Foo.is_extended)
endfunction

function! s:tc.Class_extend___it_should_include_only_exported()
  call self.assert_is(s:Foo.__bind__, self.Foo.__bind__)
endfunction

" {Class}.include()
function! s:tc.setup_Class_include()
  let Foo = deepcopy(s:Foo)
  call Foo.include(s:Buzz)
  let self.foo = Foo.new()
endfunction

function! s:tc.Class_include___it_should_include_module_functions_as_instance_methods()
  call self.assert_has_key('is_extended', self.foo)
  call self.assert_is_Funcref(self.foo.is_extended)
endfunction

function! s:tc.Class_include___it_should_include_only_exported()
  call self.assert_not_has_key('function', self.foo)
endfunction

" {Class}.ancestors()
function! s:tc.Class_ancestors___it_should_return_List_of_ancestors()
  call self.assert_equal(s:Foo.ancestors(),  [])
  call self.assert_equal(s:Baz.ancestors(),  [s:Bar, s:Foo])
endfunction

" {Class}.is_descendant_of()
function! s:tc.Class_is_descendant_of___Bar_should_be_descendant_of_Foo()
  call self.assert(s:Bar.is_descendant_of(s:Foo))
endfunction

function! s:tc.Class_is_descendant_of___Bar_should_not_be_descendant_of_Bar()
  call self.assert_not(s:Bar.is_descendant_of(s:Baz))
endfunction

" {Class}.class_method()
function! s:tc.Class_class_method___it_should_bind_Funcref_as_class_method()
  call self.assert_is_Funcref(s:Foo.hello)
  call self.assert_equal("Foo's hello", s:Foo.hello())
endfunction

function! s:tc.Class_class_method___it_should_bind_Funcref_as_class_method_with_given_name()
  call self.assert_is_Funcref(s:Foo.nihao)
  call self.assert_equal("Foo's nihao", s:Foo.nihao())

  call self.assert_not_has_key('hello_cn', s:Foo)
endfunction

" {Class}.class_alias()
function! s:tc.Class_class_alias___it_should_define_alias_of_class_method()
  call self.assert_equal(s:Foo.hello, s:Foo.hi)
endfunction

" {Class}.method()
function! s:tc.Class_method___it_should_bind_Funcref_as_instance_method()
  call self.assert_is_Funcref(self.foo.hello)
  call self.assert_equal("Foo's hello", self.foo.hello())
endfunction

function! s:tc.Class_method___it_should_bind_Funcref_as_instance_method_with_given_name()
  call self.assert_is_Funcref(self.foo.nihao)
  call self.assert_equal("Foo's nihao", self.foo.nihao())

  call self.assert_not_has_key('hello_cn', self.foo)
endfunction

" {Class}.alias()
function! s:tc.Class_alias___it_should_define_alias_of_instance_method()
  call self.assert_equal(self.foo.hello, self.foo.hi)
endfunction

" {Class}.super()
function! s:tc.Class_super___it_should_call_super_implementation()
  call self.assert_equal("Bar's hello < Foo's hello", s:Bar.hello())
  call self.assert_equal("Baz's hello < Bar's hello < Foo's hello", s:Baz.hello())

  call self.assert_equal("Bar's hello < Foo's hello", self.bar.hello())
  call self.assert_equal("Baz's hello < Bar's hello < Foo's hello", self.baz.hello())
endfunction

function! s:tc.Class_super___it_should_throw_if_not_method()
  call self.assert_throw_something('call self.Baz.super("superclass", [], self.Baz)')
  call self.assert_throw_something('call self.Baz.super("class", [], self.baz)')
endfunction

function! s:tc.Class_super___it_should_throw_if_no_super_implementation()
  call self.assert_throw('^vim-oop: ', 'call self.Baz.super("bonjour", [], self.Baz)')
  call self.assert_throw('^vim-oop: ', 'call self.Baz.super("bonjour", [], self.baz)')
endfunction

" {Class}.new()
function! s:tc.xnew_Class_new___it_should_use_extend_to_instanciate()
  let attrs = { 'a': 10, 'b': 20, 'c': 30 }
  let xfoo = s:XFoo.new(attrs)
  call self.assert_is(attrs, xfoo)
  call self.assert(oop#is_instance(xfoo))
  call self.assert(xfoo.is_a(s:XFoo))
  call self.assert_equal("XFoo's hello", xfoo.hello())
  call self.assert_equal(10, xfoo.a)
endfunction

" {Instance}.initialize()
function! s:tc.Instance_initialize___instance_should_be_initialized()
  call self.assert_has_key('initialized', self.foo)
endfunction

" {Instance}.extend()
function! s:tc.setup_Instance_extend()
  call self.foo.extend(s:Buzz)
endfunction

function! s:tc.Instance_extend___it_should_include_module_functions_as_its_methods()
  call self.assert_has_key('is_extended', self.foo)
  call self.assert_is_Funcref(self.foo.is_extended)
endfunction

function! s:tc.Instance_extend___it_should_include_only_exported()
  call self.assert_not_has_key('function', self.foo)
endfunction

" {Instance}.is_a()
function! s:tc.Instance_is_a___foo_should_be_Foo()
  call self.assert(self.foo.is_a(s:Foo))
endfunction

function! s:tc.Instance_is_a___foo_should_not_be_Bar()
  call self.assert_not(self.foo.is_a(s:Bar))
endfunction

" {Instance}.serialize()
function! s:tc.Instance_serialize___it_should_serialize_Instance_to_String()
  call self.make_object_network()
  call self.assert(oop#is_instance(self.foo))
  let str = self.foo.serialize()
  call self.assert_not(oop#is_object(str))
  call self.assert_is_String(str)

  let expected = {
        \ '__vim_oop__': 1, 'class': 'Foo', 'initialized': 1, 'value': 1,
        \ 'children': [
        \   { '__vim_oop__': 1, 'class': 'Bar', 'initialized': 1, 'value': 2 },
        \   { '__vim_oop__': 1, 'class': 'Baz', 'initialized': 1, 'value': 3 },
        \ ],
        \}
  call self.assert_equal(expected, eval(str))
endfunction

function! s:tc.make_object_network()
  let self.foo.value = 1
  let self.bar.value = 2
  let self.baz.value = 3
  let self.foo.children = [self.bar, self.baz]
endfunction

" oop#is_object()
function! s:tc.oop_is_object___Foo_should_be_Object()
  call self.assert(oop#is_object(s:Foo))
endfunction

function! s:tc.oop_is_object___foo_should_be_Object()
  call self.assert(oop#is_object(self.foo))
endfunction

" oop#is_class()
function! s:tc.oop_is_class___Foo_should_be_Class()
  call self.assert(oop#is_class(s:Foo))
endfunction

function! s:tc.oop_is_class___foo_should_not_be_Class()
  call self.assert_not(oop#is_class(self.foo))
endfunction

" oop#is_instance()
function! s:tc.oop_is_instance___Foo_should_not_be_Instance()
  call self.assert_not(oop#is_instance(s:Foo))
endfunction

function! s:tc.oop_is_instance___foo_should_be_Instance()
  call self.assert(oop#is_instance(self.foo))
endfunction

" oop#serialize()
function! s:tc.oop_serialize___it_should_stringify_value()
  call self.assert_equal(string(10), oop#serialize(10))
  call self.assert_equal(string("String"), oop#serialize("String"))
  call self.assert_equal(string([1, 2, 3]), oop#serialize([1, 2, 3]))
  call self.assert_equal({'a': 1, 'b': 2}, eval(oop#serialize({'a': 1, 'b': 2}))) 
endfunction

function! s:tc.oop_serialize___it_should_throw_when_Class_is_given()
  call self.assert_throw('^vim-oop: ', 'call oop#serialize(self.Foo)')
endfunction

function! s:tc.oop_serialize___it_should_throw_when_Module_is_given()
  call self.assert_throw('^vim-oop: ', 'call oop#serialize(self.Buzz)')
endfunction

" oop#deserialize()
function! s:tc.oop_deserialize___it_should_deserialize_Instance_from_String()
  call self.make_object_network()
  let str = self.foo.serialize()
  call self.assert_equal(self.foo, oop#deserialize(str, s:SID() . 'name_to_class'))
endfunction

function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID')
endfunction

function! s:name_to_class(name)
  return s:tc[a:name]
endfunction

" oop#string()
function! s:tc.oop_string___it_should_stringify_value()
  call self.assert_equal(string(10), oop#string(10))
  call self.assert_equal(string("String"), oop#string("String"))
  call self.assert_equal(string([1, 2, 3]), oop#string([1, 2, 3]))
  call self.assert_equal({'a': 1, 'b': 2}, eval(oop#string({'a': 1, 'b': 2})))
endfunction

function! s:tc.v_oop_string___it_should_stringify_Class()
  let str = oop#string(s:Bar)
  call self.assert_is_String(str)
  call self.puts()
  call self.puts("Dumped class Bar:")
  call self.puts(str)
endfunction

function! s:tc.v_oop_string___it_should_stringify_Instance()
  let str = oop#string(self.foo)
  call self.assert_is_String(str)
  call self.puts()
  call self.puts("Dumped instance foo:")
  call self.puts(str)
endfunction

function! s:tc.v_oop_string___it_should_stringify_Object_network()
  let str = oop#string(self.foo)
  call self.assert_is_String(str)
  call self.puts()
  call self.puts("Dumped object network:")
  call self.puts(str)
endfunction

function! s:tc.v_oop_string___it_should_stringify_Module()
  let str = oop#string(s:Buzz)
  call self.assert_is_String(str)
  call self.puts()
  call self.puts("Dumped module Buzz:")
  call self.puts(str)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
