" vim-oop's test suite

let here = expand('<sfile>:p:h')
execute 'source' here . '/test_base.vim'
execute 'source' here . '/test_funcs.vim'
execute 'source' here . '/test_object.vim'
execute 'source' here . '/test_class.vim'
execute 'source' here . '/test_module.vim'

" vim: filetype=vim
