
nmap <leader>p <cmd>call python#interactive()<cr>
nmap <leader>q <cmd>call python#uninteract()<cr>
nnoremap <leader>a <cmd>call python#addargument()<cr>
nnoremap <leader>m <cmd>call python#addmember()<cr>
nnoremap <leader>i <cmd>call python#addimport()<cr>
nnoremap <leader>f <cmd>call python#addflag()<cr> 
nnoremap ts <cmd>call python#togglemember()<cr>
noremap mp <cmd>call python#run()<cr>

nmap <C-S><C-J> <cmd>call python#jupyter()<cr>

if expand('%:e') == 'ipynb'
    setlocal foldmethod=expr
    setlocal foldexpr=python#ipynb_fold()
endif


call python#pythonsetup()

compiler python
