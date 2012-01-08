" vim-oop's test suite

let here = expand('<sfile>:p:h')
execute 'source' here . '/test_class.vim'
execute 'source' here . '/test_module.vim'
