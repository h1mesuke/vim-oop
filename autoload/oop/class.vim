"=============================================================================
" vim-oop
" Simple OOP Layer for Vim script
"
" File    : oop/class.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2012-01-19
" Version : 0.2.3
" License : MIT license {{{
"
"   Permission is hereby granted, free of charge, to any person obtaining
"   a copy of this software and associated documentation files (the
"   "Software"), to deal in the Software without restriction, including
"   without limitation the rights to use, copy, modify, merge, publish,
"   distribute, sublicense, and/or sell copies of the Software, and to
"   permit persons to whom the Software is furnished to do so, subject to
"   the following conditions:
"
"   The above copyright notice and this permission notice shall be included
"   in all copies or substantial portions of the Software.
"
"   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:TYPE_NUM  = type(0)
let s:TYPE_FUNC = type(function('tr'))

"-----------------------------------------------------------------------------
" Class

" NOTE: Omit type checking for efficiency.
function! oop#class#get(name)
  let ns = oop#__namespace__()
  return ns[a:name]
endfunction

" oop#class#new( {name}, {sid} [, {superclass}])
"
" Creates a new class. The second argument must be the SID number or prefix of
" the script where the class is defined.
"
"   function! s:get_SID()
"     return matchstr(expand('<sfile>'), '<SNR>\d\+_')
"   endfunction
"   let s:SID = s:get_SID()
"   delfunction s:get_SID
"
"   s:Foo = oop#class#new('Foo', s:SID)
"
" To create a derived class, give the base class as the third argument.
"
"   s:Bar = oop#class#new('Bar', s:SID, s:Foo)
"
function! oop#class#new(name, sid, ...)
  let ns = oop#__namespace__()
  if has_key(ns, a:name)
    throw "vim-oop: Name conflict: " . a:name
  endif
  let class = copy(s:Class)
  let class.name = a:name
  let sid = (type(a:sid) == s:TYPE_NUM ? a:sid : matchstr(a:sid, '\d\+'))
  let class.__sid_prefix__ = printf('<SNR>%d_%s_', sid, a:name)
  "=> <SNR>10_Foo_
  let class.__prototype__ = copy(s:Instance)
  let class.superclass = (a:0 ? a:1 : {})
  " Inherit methods from superclasses.
  for klass in class.ancestors()
    call extend(class, klass, 'keep')
    call extend(class.__prototype__, klass.__prototype__, 'keep')
  endfor
  let ns[a:name] = class
  return class
endfunction

"-----------------------------------------------------------------------------

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

let s:Class = { '__vim_oop__': 1 }

function! s:Object_extend(module, ...) dict
  let mode = (a:0 ? a:1 : 'force')
  call s:extend(self, a:module, mode)
endfunction

" Adds {module}'s functions to the class as class methods.
"
"   s:Foo.extend(s:Buzz)
"
let s:Class.extend = function(s:SID . 'Object_extend')

" Adds {module}'s functions to the class as instance methods.
"
"   s:Foo.include(s:Buzz)
"
function! s:Class_include(module, ...) dict
  let mode = (a:0 ? a:1 : 'force')
  call s:extend(self.__prototype__, a:module, mode)
endfunction
let s:Class.include = function(s:SID . 'Class_include')

function! s:extend(dict, module, mode)
  let funcs = {}
  for func_name in a:module.__funcs__
    let funcs[func_name] = a:module[func_name]
  endfor
  call extend(a:dict, funcs, a:mode)
endfunction

" Returns a List of ancestor classes.
"
function! s:Class_ancestors() dict
  let ancestors = []
  let klass = self.superclass
  while !empty(klass)
    call add(ancestors, klass)
    let klass = klass.superclass
  endwhile
  return ancestors
endfunction
let s:Class.ancestors = function(s:SID . 'Class_ancestors')

" Returns True if the class is a descendant of {class}.
"
"   if s:Bar.is_descendant_of(s:Foo)
"   endif
"
function! s:Class_is_descendant_of(class) dict
  return index(self.ancestors(), a:class) >= 0
endfunction
let s:Class.is_descendant_of = function(s:SID . 'Class_is_descendant_of')

" Binds function {func_name} to a class Dictionary as a class method of the
" class.
"
" The name of the function to be bound must be prefixed by the class name
" followed by one underscore. This convention helps you to distinguish method
" functions from other functions.
"
"   function! s:Foo_hello() dict
"   endfunction
"   call s:Foo.class_method('hello')
"
" Note that however the names of methods themselves don't include the prefix.
"
"   call Foo.hello()
"
function! s:Class_class_bind(func_name, ...) dict
  let meth_name = (a:0 ? a:1 : a:func_name)
  let self[meth_name] = function(self.__sid_prefix__  . a:func_name)
endfunction
let s:Class.__class_bind__ = function(s:SID . 'Class_class_bind')
let s:Class.class_method = s:Class.__class_bind__ | " syntax sugar

" Binds function {func_name} to a class prototype Dictionary as an instance
" method of the class.
"
" The name of the function to be bound must be prefixed by the class name
" followed by one underscore. This convention helps you to distinguish method
" functions from other functions.
"
"   function! s:Foo_hello() dict
"   endfunction
"   call s:Foo.method('hello')
"
" Note that however the names of methods themselves don't include the prefix.
"
"   call foo.hello()
"
function! s:Class_bind(func_name, ...) dict
  let meth_name = (a:0 ? a:1 : a:func_name)
  let self.__prototype__[meth_name] = function(self.__sid_prefix__  . a:func_name)
endfunction
let s:Class.__bind__ = function(s:SID . 'Class_bind')
let s:Class.method = s:Class.__bind__ | " syntax sugar

" Defines an alias of class method {meth_name}.
"
"   call s:Foo.class_alias('hi', 'hello')
"
function! s:Class_class_alias(alias, meth_name) dict
  if has_key(self, a:meth_name) && type(self[a:meth_name]) == s:TYPE_FUNC
    let self[a:alias] = self[a:meth_name]
  else
    throw "vim-oop: " . self.name . "." . a:meth_name . "() is not defined."
  endif
endfunction
let s:Class.class_alias = function(s:SID . 'Class_class_alias')

" Defines an alias of instance method {meth_name}.
"
"   call s:Foo.alias('hi', 'hello')
"
function! s:Class_alias(alias, meth_name) dict
  if has_key(self.__prototype__, a:meth_name) &&
        \ type(self.__prototype__[a:meth_name]) == s:TYPE_FUNC
    let self.__prototype__[a:alias] = self.__prototype__[a:meth_name]
  else
    throw "vim-oop: " . self.name . "#" . a:meth_name . "() is not defined."
  endif
endfunction
let s:Class.alias = function(s:SID . 'Class_alias')

" {Class}.super( {meth_name}, {args}, {self})
"
" Calls the superclass's implementation of method {meth_name} in the manner of
" built-in call().
"
"   function! s:Bar_hello() dict
"     return 'Bar < ' . s:Bar.super('hello', [], self)
"   endfunction
"   call s:Bar.class_method('hello')
"   call s:Bar.method('hello')
"
function! s:Class_super(meth_name, args, _self) dict
  let is_class = oop#is_class(a:_self)
  let meth_table = (is_class ? self : self.__prototype__)

  let has_impl = (has_key(meth_table, a:meth_name) &&
        \ type(meth_table[a:meth_name]) == s:TYPE_FUNC)

  for klass in self.ancestors()
      let kls_meth_table = (is_class ? klass : klass.__prototype__)
    if has_key(kls_meth_table, a:meth_name)
      if type(kls_meth_table[a:meth_name]) != s:TYPE_FUNC
        let sep = (is_class ? '.' : '#')
        throw "vim-oop: " . klass.name . sep . a:meth_name . " is not a method."
      elseif !has_impl || (has_impl && meth_table[a:meth_name] != kls_meth_table[a:meth_name])
        return call(kls_meth_table[a:meth_name], a:args, a:_self)
      endif
    endif
  endfor
  let sep = (is_class ? '.' : '#')
  throw "vim-oop: " . self.name . sep .
        \ a:meth_name . "()'s super implementation was not found."
endfunction
let s:Class.super = function(s:SID . 'Class_super')

" Instantiates an object.
"
"   let foo = s:Foo.new()
"
function! s:Class_new(...) dict
  let obj = copy(self.__prototype__)
  let obj.class = self
  call call(obj.initialize, a:000, obj)
  return obj
endfunction
let s:Class.new = function(s:SID . 'Class_new')

" Promotes an attributes Dictionary to an object.
"
"   let foo = s:Foo.promote(attrs)
"
function! s:Class_promote(attrs, ...) dict
  let obj = extend(a:attrs, self.__prototype__, 'keep')
  let obj.class = self
  call call(obj.initialize, a:000, obj)
  return obj
endfunction
let s:Class.promote = function(s:SID . 'Class_promote')

"-----------------------------------------------------------------------------
" Instance

let s:Instance = { '__vim_oop__': 1 }

" Initializes the object. This method will be called for each newly created
" object as a part of its instanciation process. User-defined classes should
" override this method for their specific initialization.
"
"   let s:Foo = oop#class#new('Foo')
"
"   function! s:Foo_initialize(x, y) dict
"     let self.x = a:x
"     let self.y = a:y
"   endfunction
"   call s:Foo.method('initialize')
"
function! s:Instance_initialize(...) dict
endfunction
let s:Instance.initialize = function(s:SID . 'Instance_initialize')

" Adds {module}'s functions to the object as its methods.
"
"   foo.extend(s:Buzz)
"
let s:Instance.extend = function(s:SID . 'Object_extend')

" Returns True if the object is an instance of {class} or one of its
" ancestors.
"
"   if foo.is_a(s:Foo)
"   endif
"
function! s:Instance_is_kind_of(class) dict
  return (self.class is a:class || self.class.is_descendant_of(a:class))
endfunction
let s:Instance.is_kind_of = function(s:SID . 'Instance_is_kind_of')
let s:Instance.is_a = function(s:SID . 'Instance_is_kind_of')

" Demotes the object to an attributes Dictionary.
"
function! s:Instance_demote() dict
  let self.class = self.class.name
  call filter(self, 'type(v:val) != s:TYPE_FUNC')
  call remove(self, '__vim_oop__')
endfunction
let s:Instance.demote = function(s:SID . 'Instance_demote')

" Serializes the object.
"
function! s:Instance_serialize() dict
  return oop#string(self)
endfunction
let s:Instance.serialize = function(s:SID . 'Instance_serialize')

let &cpo = s:save_cpo
unlet s:save_cpo
