
nmap <leader>p <cmd>call python#interactive()<cr>
nmap <leader>q <cmd>call python#uninteract()<cr>
nnoremap <leader>a <cmd>call python#addargument()<cr>
nnoremap <leader>m <cmd>call python#addmember()<cr>
nnoremap <leader>i <cmd>call python#addimport()<cr>
nnoremap <leader>f <cmd>call python#addflag()<cr> 
nnoremap ts <cmd>call python#togglemember()<cr>
noremap mp <cmd>call python#run()<cr>


if expand('%:e') == 'ipynb'
    setlocal foldmethod=expr
    setlocal foldexpr=python#ipynb_fold()
    nnoremap <buffer> <space>j <cmd>call python#cell_below()<cr>
    nnoremap <buffer> <space>k <cmd>call python#cell_above()<cr>
    nnoremap <buffer> <space>- <cmd>call python#cell_split()<cr>
    nnoremap <buffer> <C-J> zj
    nnoremap <buffer> <C-K> zk
    augroup ipynb
        autocmd!
        autocmd BufWinEnter *.ipynb let b:matchtitle = matchadd('ToolbarButton', '###.*')
        autocmd BufWinLeave *.ipynb silent! call matchdelete(b:matchtitle)
    augroup END
    nnoremap <C-S><C-J> <cmd>call python#aspy()<cr>
else
    nnoremap <C-S><C-J> <cmd>call python#asipynb()<cr>
endif


call python#pythonsetup()

compiler python
