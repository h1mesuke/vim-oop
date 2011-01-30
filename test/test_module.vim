" vim-oop's test suite

execute 'source' expand('<sfile>:p:h') . '/init_oop.vim'
let tc = unittest#testcase#new('test_class')

let s:Object = oop#class#get('Object')
let s:Class  = oop#class#get('Class')
let s:Module = oop#class#get('Module')

let s:Baz    = oop#class#get('Baz')   | let tc.Baz  = s:Baz

let s:Fizz   = oop#module#get('Fizz') | let tc.Fizz = s:Fizz
let s:Buzz   = oop#module#get('Buzz') | let tc.Buzz = s:Buzz

call s:Baz.class_mixin('Fizz')
call s:Baz.mixin('Buzz')

"-----------------------------------------------------------------------------

function! tc.setup()
  let self.baz = s:Baz.new()
endfunction

" Module.is_defined()
function! tc.Fizz_should_be_defined()
  call assert#true(oop#module#is_defined('Fizz'))
endfunction

function! tc.Foo_should_not_be_defined()
  call assert#false(oop#module#is_defined('Foo'))
endfunction

" Module#alias()
function! tc.Module_alias_should_define_alias_of_instance_method()
  call assert#equal(s:Fizz.hello, s:Fizz.hello_alias)
endfunction

" Module#bind()
function! tc.Module_bind_should_bind_Funcref_as_module_method()
  call assert#equal("Fizz", s:Fizz.hello())
  call assert#equal("Buzz", s:Buzz.hello())
endfunction

function! tc.Module_bind_should_has_underscored_alias()
  call assert#equal(s:Module.__bind__, s:Module.bind)
endfunction

" Module#unbind()
function! tc.Module_unbind_should_has_underscored_alias()
  call assert#equal(s:Module.__unbind__, s:Module.unbind)
endfunction

" Module#inspect()
function! tc.Module_inspect_should_return_string_rep()
  call assert#nothing_raised('call unittest#testcase().Fizz.inspect()')
  call assert#nothing_raised('call unittest#testcase().Buzz.inspect()')

  call self.puts()
  call self.puts(self.Fizz.inspect())
endfunction

" Module#is_a()
function! tc.Module_is_a_should_be_alias_of_Module_is_kind_of()
  call assert#equal(s:Fizz.is_kind_of, s:Fizz.is_a)
endfunction

" Module#is_instance_of()
function! tc.Fizz_should_be_instance_of_Module()
  call assert#true(s:Fizz.is_instance_of(s:Module))
endfunction

function! tc.Module_is_instance_of_should_raise_if_not_class_value_given()
  for value_str in s:not_class_value_strings()
    call assert#raise('^oop: ', 'call unittest#testcase().Fizz.is_instance_of(' . value_str . ')')
  endfor
endfunction

" Module#is_kind_of()
function! tc.Fizz_should_be_kind_of_Module()
  call assert#true(s:Fizz.is_kind_of(s:Module))
endfunction

function! tc.Module_is_kind_of_should_raise_if_not_class_value_given()
  for value_str in s:not_class_value_strings()
    call assert#raise('^oop: ', 'call unittest#testcase().Fizz.is_kind_of(' . value_str . ')')
  endfor
endfunction

" Module#name
function! tc.Module_name_should_be_class_name()
  call assert#equal('Fizz', s:Fizz.name)
  call assert#equal('Buzz', s:Buzz.name)
endfunction

" Module#object_id
function! tc.Module_object_id_should_be_unique_Number()
  call assert#is_Number(s:Fizz.object_id)
  call assert#is_Number(s:Buzz.object_id)
  call assert#not_equal(s:Buzz.object_id, s:Fizz.object_id)
endfunction

" Module#to_s()
function! tc.Module_to_s_should_return_string_rep()
  call assert#equal('Fizz', s:Fizz.to_s())
  call assert#equal('Buzz', s:Buzz.to_s())

  call self.puts()
  call self.puts(s:Fizz.to_s())
  call self.puts(s:Buzz.to_s())
endfunction

function! s:not_class_value_strings()
  return ['unittest#testcase().Fizz', '0', '""', 'function("tr")', '[]', '{}', '0.0']
endfunction

" Class#class_mixin
function! tc.Class_class_mixin_should_mixin_module_method()
  call assert#equal('Fizz', s:Baz.hello())
endfunction

function! tc.Class_class_mixin_should_raise_if_not_module_value_given()
  for value_str in s:not_module_value_strings()
    call assert#raise('^oop: ', 'call unittest#testcase().Baz.mixin(' . value_str . ')')
  endfor
endfunction

" Class#mixin
function! tc.Class_mixin_should_mixin_module_method()
  call assert#equal('Buzz', self.baz.hello())
endfunction

function! tc.Class_mixin_should_raise_if_not_module_value_given()
  for value_str in s:not_module_value_strings()
    call assert#raise('^oop: ', 'call unittest#testcase().baz.mixin(' . value_str . ')')
  endfor
endfunction

" Object#mixin
function! tc.Object_mixin_should_mixin_module_method()
  call self.baz.mixin('Fizz')
  call assert#equal('Fizz', self.baz.hello())
endfunction

function! s:not_module_value_strings()
  return ['unittest#testcase().baz', '0', '""', 'function("tr")', '[]', '{}', '0.0']
endfunction

unlet tc

" vim: filetype=vim
