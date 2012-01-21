" vim-oop's test suite

let s:here = expand('<sfile>:p:h')
execute 'source' s:here . '/test_class.vim'
execute 'source' s:here . '/test_module.vim'
