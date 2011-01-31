" vim-oop's test suite

execute 'source' expand('<sfile>:p:h') . '/init_oop.vim'
let tc = unittest#testcase#new('test_funcs')

let s:Object = oop#class#get('Object')
let s:Class  = oop#class#get('Class')
let s:Module = oop#class#get('Module')

let s:Foo    = oop#class#get('Foo')
let s:Fizz   = oop#module#get('Fizz')

"-----------------------------------------------------------------------------

function! tc.setup()
  let self.foo = s:Foo.new()
endfunction

" oop#is_object()
function! tc.test_oop_is_object()
  call assert#true(oop#is_object(s:Object))
  call assert#true(oop#is_object(s:Module))
  call assert#true(oop#is_object(s:Class))
  call assert#true(oop#is_object(s:Foo))
  call assert#true(oop#is_object(s:Fizz))
  call assert#true(oop#is_object(self.foo))

  for s:value in s:not_object_values()
    call assert#false(oop#is_object(s:value))
    unlet s:value
  endfor
endfunction

" oop#is_module()
function! tc.test_oop_is_module()
  call assert#false(oop#is_module(s:Object))
  call assert#false(oop#is_module(s:Class))
  call assert#false(oop#is_module(s:Module))
  call assert#false(oop#is_module(s:Foo))
  call assert#true(oop#is_module(s:Fizz))
  call assert#false(oop#is_module(self.foo))

  for s:value in s:not_object_values()
    call assert#false(oop#is_module(s:value))
    unlet s:value
  endfor
endfunction

" oop#is_class()
function! tc.test_oop_is_class()
  call assert#true(oop#is_class(s:Object))
  call assert#true(oop#is_class(s:Class))
  call assert#true(oop#is_class(s:Module))
  call assert#true(oop#is_class(s:Foo))
  call assert#false(oop#is_class(s:Fizz))
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
  call assert#false(oop#is_instance(s:Module))
  call assert#false(oop#is_instance(s:Object))
  call assert#false(oop#is_instance(s:Foo))
  call assert#false(oop#is_instance(s:Fizz))
  call assert#true(oop#is_instance(self.foo))

  for s:value in s:not_object_values()
    call assert#false(oop#is_instance(s:value))
    unlet s:value
  endfor
endfunction

" oop#inspect()
function! tc.test_oop_inspect()
  " should not raise an error
  for s:value in s:not_object_values()
    call oop#inspect(s:value)
    unlet s:value
  endfor

  call self.puts()
  call self.puts(oop#inspect(self.foo))
  call self.puts()
  call self.puts(oop#inspect([self.foo]))
  call self.puts(oop#inspect({ 'foo': self.foo }))
endfunction

" oop#to_s()
function! tc.test_oop_to_s()
  " should not raise an error
  for s:value in s:not_object_values()
    call oop#to_s(s:value)
    unlet s:value
  endfor

  call self.puts()
  call self.puts(oop#to_s(self.foo))
  call self.puts()
  call self.puts(oop#to_s({ 'foo': self.foo }))
  call self.puts(oop#to_s([self.foo]))
endfunction

function! s:not_object_values()
  return [0, "", function('tr'), [], {}, 0.0]
endfunction

unlet tc

" vim: filetype=vim
