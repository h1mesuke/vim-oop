" vim-oop's test suite

execute 'source' expand('<sfile>:p:h') . '/init_oop.vim'
let tc = unittest#testcase#new('test_object')

let s:Object = oop#class#get('Object')

let s:Foo    = oop#class#get('Foo') | let tc.Foo = s:Foo
let s:Bar    = oop#class#get('Bar') | let tc.Bar = s:Bar
let s:Baz    = oop#class#get('Baz') | let tc.Baz = s:Baz

"-----------------------------------------------------------------------------

function! tc.setup()
  let self.foo = s:Foo.new()
  let self.bar = s:Bar.new()
  let self.baz = s:Baz.new()
endfunction

" Object#initialize()
function! tc.instance_should_be_initialized()
  call assert#true(has_key(self.foo, 'initialized'))
endfunction

" Object#attributes()
function! tc.setup_Object_attributes()
  let self.foo.a = 10
  let self.foo.b = 11
  let self.foo.c = 12
endfunction

function! tc.Object_attributes_should_return_Dict_of_attributes()
  let attrs = self.foo.attributes()

  call assert#is_Dictionary(attrs)
  call assert#true(has_key(attrs, 'a'))
  call assert#false(has_key(attrs, 'class'))
  call assert#false(has_key(attrs, 'object_id'))
  call assert#equal(
        \ len(attrs),
        \ len(filter(copy(attrs), 'type(v:val) != type(function("tr"))')))

  call self.puts()
  call self.puts(oop#to_s(attrs))
endfunction

function! tc.Object_attributes_1_should_return_Dict_of_all_attributes()
  let attrs = self.foo.attributes(1)

  call assert#is_Dictionary(attrs)
  call assert#true(has_key(attrs, 'a'))
  call assert#false(has_key(attrs, 'class'))
  call assert#true(has_key(attrs, '__class__'))
  call assert#true(has_key(attrs, 'object_id'))
  call assert#equal(
        \ len(attrs),
        \ len(filter(copy(attrs), 'type(v:val) != type(function("tr"))')))

  call self.puts()
  call self.puts(oop#to_s(attrs))
endfunction

" Object#inspect()
function! tc.Object_inspect_should_return_string_rep()
  call assert#nothing_raised('call unittest#testcase().foo.inspect()')
  call assert#nothing_raised('call unittest#testcase().bar.inspect()')

  call self.puts()
  call self.puts(self.foo.inspect())
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

function! tc.Object_is_kind_of_should_raise_if_not_class_value_given()
  for value_str in s:not_class_value_strings()
    call assert#raise('^oop: ', 'call unittest#testcase().foo.is_kind_of(' . value_str . ')')
  endfor
endfunction

" Object#object_id
function! tc.Object_object_id_should_be_unique_Number()
  call assert#is_Number(self.foo.object_id)
  call assert#is_Number(self.bar.object_id)
  call assert#not_equal(self.foo.object_id, self.bar.object_id)
endfunction

" Object#to_s()
function! tc.Object_to_s_should_return_string_rep()
  call assert#match('<Foo:0x\x\{8}>', self.foo.to_s())
  call assert#match('<Bar:0x\x\{8}>', self.bar.to_s())

  call self.puts()
  call self.puts(self.foo.to_s())
  call self.puts(self.bar.to_s())
endfunction

function! s:not_class_value_strings()
  return ['unittest#testcase().foo', '0', '""', 'function("tr")', '[]', '{}', '0.0']
endfunction

unlet tc

" vim: filetype=vim
