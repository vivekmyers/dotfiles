
setlocal tags+=~/.vim/tags
setlocal iskeyword+=:

" nnoremap <cr> <cmd>call vim#exec()<cr>
call operator#user#define('vim-exec', 'vim#exec')
map <buffer> <cr> <plug>(operator-vim-exec)

