" vim-oop's test suite

execute 'source' expand('<sfile>:p:h') . '/init_oop.vim'
let tc = unittest#testcase#new('test_class')

let s:Object = oop#class#get('Object')
let s:Class  = oop#class#get('Class')

let s:Foo    = oop#class#get('Foo') | let tc.Foo = s:Foo
let s:Bar    = oop#class#get('Bar') | let tc.Bar = s:Bar
let s:Baz    = oop#class#get('Baz') | let tc.Baz = s:Baz

"-----------------------------------------------------------------------------

function! tc.setup()
  let self.foo = s:Foo.new()
  let self.bar = s:Bar.new()
  let self.baz = s:Baz.new()
endfunction

" Class.is_defined()
function! tc.Foo_should_be_defined()
  call assert#true(oop#class#is_defined('Foo'))
endfunction

function! tc.Fizz_should_not_be_defined()
  call assert#false(oop#class#is_defined('Fizz'))
endfunction

" Class.new()
function! tc.class_methods_should_be_inherited()
  call assert#equal(s:Object.to_s, s:Foo.to_s)
  call assert#equal("Foo", s:Bar.goodbye())
  call assert#equal("Foo", s:Baz.goodbye())
endfunction

function! tc.instance_methods_should_be_inherited()
  call assert#equal(s:Object.prototype.to_s, self.foo.to_s)
  call assert#equal("foo", self.bar.goodbye())
  call assert#equal("foo", self.baz.goodbye())
endfunction

" Class#alias()
function! tc.Class_alias_should_define_alias_of_instance_method()
  call assert#equal(self.foo.hello, self.foo.hello_alias)
endfunction

" Class#ancestors()
function! tc.Class_ancestors_should_return_superclass_list()
  call assert#equal(s:Baz.ancestors(),  [s:Bar, s:Foo, s:Object])
  call assert#equal(s:Baz.ancestors(1), [s:Baz, s:Bar, s:Foo, s:Object])
endfunction

" Class#bind()
function! tc.Class_bind_should_bind_Funcref_as_instance_method()
  call assert#equal("foo", self.foo.hello())
  call assert#equal("bar", self.bar.hello())
endfunction

function! tc.Class_bind_should_has_underscored_alias()
  call assert#equal(s:Class.__bind__, s:Class.bind)
endfunction

" Class#unbind()
function! tc.Class_unbind_should_has_underscored_alias()
  call assert#equal(s:Class.__unbind__, s:Class.unbind)
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

" Class#export()
function! tc.Class_export_should_export_instance_method_as_class_method()
  call assert#equal(s:Foo.hello_export, self.foo.hello_export)
endfunction

function! tc.Class_export_should_has_underscored_alias()
  call assert#equal(s:Class.__export__, s:Class.export)
endfunction

" Class#inspect()
function! tc.Class_inspect_should_return_string_rep()
  call assert#nothing_raised('call unittest#testcase().Foo.inspect()')
  call assert#nothing_raised('call unittest#testcase().Bar.inspect()')

  call self.puts()
  call self.puts(self.Foo.inspect())
endfunction

" Class#is_a()
function! tc.Class_is_a_should_be_alias_of_Class_is_kind_of()
  call assert#equal(s:Foo.is_kind_of, s:Foo.is_a)
endfunction

" Class#is_instance_of()
function! tc.Foo_should_be_instance_of_Class()
  call assert#true(s:Foo.is_instance_of(s:Class))
endfunction

function! tc.Class_is_instance_of_should_raise_if_not_class_value_given()
  for value_str in s:not_class_value_strings()
    call assert#raise('^oop: ', 'call unittest#testcase().Foo.is_instance_of(' . value_str . ')')
  endfor
endfunction

" Class#is_kind_of()
function! tc.Foo_should_be_kind_of_Class()
  call assert#true(s:Foo.is_kind_of(s:Class))
endfunction

function! tc.Class_is_kind_of_should_raise_if_not_class_value_given()
  for value_str in s:not_class_value_strings()
    call assert#raise('^oop: ', 'call unittest#testcase().Foo.is_kind_of(' . value_str . ')')
  endfor
endfunction

" Class#name
function! tc.Class_name_should_be_class_name()
  call assert#equal('Foo', s:Foo.name)
  call assert#equal('Bar', s:Bar.name)
endfunction

" Class#object_id
function! tc.Class_object_id_should_be_unique_Number()
  call assert#is_Number(s:Foo.object_id)
  call assert#is_Number(s:Bar.object_id)
  call assert#not_equal(s:Bar.object_id, s:Foo.object_id)
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
function! tc.superclass_of_Foo_should_be_Object()
  call assert#is(s:Object, s:Foo.superclass)
endfunction

function! tc.superclass_of_Bar_should_be_Foo()
  call assert#is(s:Foo, s:Bar.superclass)
endfunction

" Class#to_s()
function! tc.Class_to_s_should_return_string_rep()
  call assert#equal('Foo', s:Foo.to_s())
  call assert#equal('Bar', s:Bar.to_s())

  call self.puts()
  call self.puts(s:Foo.to_s())
  call self.puts(s:Bar.to_s())
endfunction

function! s:not_class_value_strings()
  return ['unittest#testcase().foo', '0', '""', 'function("tr")', '[]', '{}', '0.0']
endfunction

unlet tc

" vim: filetype=vim
