" vim-oop's test suite

execute 'source' expand('<sfile>:p:h') . '/init_oop.vim'
let tc = unittest#testcase#new('test_funcs')

let s:Object = oop#class#get('Object')
let s:Class  = oop#class#get('Class')

let s:Foo    = oop#class#get('Foo')

"-----------------------------------------------------------------------------

function! tc.setup()
  let self.foo = s:Foo.new()
endfunction

" oop#is_object()
function! tc.test_oop_is_object()
  call assert#true(oop#is_object(s:Object))
  call assert#true(oop#is_object(s:Class))
  call assert#true(oop#is_object(s:Foo))
  call assert#true(oop#is_object(self.foo))

  for s:value in s:not_object_values()
    call assert#false(oop#is_object(s:value))
    unlet s:value
  endfor
endfunction

" oop#is_class()
function! tc.test_oop_is_class()
  call assert#true(oop#is_class(s:Object))
  call assert#true(oop#is_class(s:Class))
  call assert#true(oop#is_class(s:Foo))
  call assert#false(oop#is_class(self.foo))

  for s:value in s:not_object_values()
    call assert#false(oop#is_class(s:value))
    unlet s:value
  endfor
endfunction

" oop#is_instance()
function! tc.test_oop_is_instance()
  call assert#false(oop#is_instance(s:Object))
  call assert#false(oop#is_instance(s:Class))
  call assert#false(oop#is_instance(s:Object))
  call assert#false(oop#is_instance(s:Foo))
  call assert#true(oop#is_instance(self.foo))

  for s:value in s:not_object_values()
    call assert#false(oop#is_instance(s:value))
    unlet s:value
  endfor
endfunction

" oop#inspect()
function! tc.test_oop_inspect()
  let str = oop#inspect(self.foo)

  call assert#match("'class': 'Foo'", str)
  call assert#match("'hello': function('<SNR>\\d\\+_Foo_hello')", str)

  call self.puts()
  call self.puts(str)

  let dict = { 'foo': self.foo, 'dict': { 'foo': self.foo } }
  let list = [self.foo, [self.foo]]

  let copy_dict = copy(dict)
  let copy_list = copy(list)

  call self.puts()
  " should not raise an error
  call self.puts(oop#inspect(dict))
  call self.puts(oop#inspect(list))
  " should not change
  call assert#equal(copy_dict, dict)
  call assert#equal(copy_list, list)

  " should not raise an error
  for s:value in s:not_object_values()
    call oop#inspect(s:value)
    unlet s:value
  endfor
endfunction

" oop#to_s()
function! tc.test_oop_to_s()
  let str = oop#to_s(self.foo)

  call assert#match('<Foo:0x\x\{8}>', str)

  call self.puts()
  call self.puts(str)

  let dict = { 'foo': self.foo, 'dict': { 'foo': self.foo } }
  let list = [self.foo, [self.foo]]

  let copy_dict = copy(dict)
  let copy_list = copy(list)

  call self.puts()
  " should not raise an error
  call self.puts(oop#to_s(dict))
  call self.puts(oop#to_s(list))
  " should not change
  call assert#equal(copy_dict, dict)
  call assert#equal(copy_list, list)

  " should not raise an error
  for s:value in s:not_object_values()
    call oop#to_s(s:value)
    unlet s:value
  endfor
endfunction

function! s:not_object_values()
  return [0, "", function('tr'), [], {}, 0.0]
endfunction

unlet tc

" vim: filetype=vim
