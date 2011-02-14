" vim-oop's test suite

execute 'source' expand('<sfile>:p:h') . '/init_oop.vim'
let tc = unittest#testcase#new('test_base')

let s:Object = oop#class#get('Object')
let s:Class  = oop#class#get('Class')
let s:Module = oop#class#get('Module')

"-----------------------------------------------------------------------------

function! tc.Object_should_be_defined()
  call assert#_(oop#class#is_defined('Object'))
endfunction

function! tc.Class_should_be_defined()
  call assert#_(oop#class#is_defined('Class'))
endfunction

function! tc.Module_should_be_defined()
  call assert#_(oop#class#is_defined('Module'))
endfunction

function! tc.object_id_of_Class_should_be_1001()
  call assert#equal(1001, s:Class.object_id)
endfunction

function! tc.object_id_of_Object_should_be_1002()
  call assert#equal(1002, s:Object.object_id)
endfunction

function! tc.object_id_of_Module_should_be_1003()
  call assert#equal(1003, s:Module.object_id)
endfunction

" Object -(class)-> Class
function! tc.class_of_Object_should_be_Class()
  call assert#is(s:Class, s:Object.class)
endfunction

function! tc.Object_should_be_instance_of_Class()
  call assert#_(s:Object.is_instance_of(s:Class))
endfunction

" Class -(class)-> Class -(class)-> ...
function! tc.class_of_Class_should_be_Class()
  call assert#is(s:Class, s:Class.class)
endfunction

function! tc.Class_should_be_instance_of_Class()
  call assert#_(s:Class.is_instance_of(s:Class))
endfunction

function! tc.Class_should_behave_as_instance_of_Class()
  call assert#equal_C('Class', s:Class.name,   'name')
  call assert#equal_C('Class', s:Class.to_s(), 'to_s()')
endfunction

" Module -(class)-> Class
function! tc.class_of_Module_should_be_Class()
  call assert#is(s:Class, s:Module.class)
endfunction

function! tc.Module_should_be_instance_of_Class()
  call assert#_(s:Module.is_instance_of(s:Class))
endfunction

" Object -(superclass)-> {}
function! tc.superclass_of_Object_should_be_empty()
  call assert#_(empty(s:Object.superclass))
endfunction

" Class -(superclass)-> Object
function! tc.superclass_of_Class_should_be_Object()
  call assert#is(s:Class.superclass, s:Object)
endfunction

" Module -(superclass)-> Class
function! tc.superclass_of_Module_should_be_Class()
  call assert#is(s:Module.superclass, s:Class)
endfunction

function! tc.Object_should_be_kind_of_Object()
  call assert#_(s:Object.is_kind_of(s:Object))
endfunction

function! tc.Class_should_be_kind_of_Object()
  call assert#_(s:Class.is_kind_of(s:Object))
endfunction

function! tc.Module_should_be_kind_of_Object()
  call assert#_(s:Module.is_kind_of(s:Object))
endfunction

unlet tc

" vim: filetype=vim
