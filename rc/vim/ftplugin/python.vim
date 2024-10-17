nnoremap <leader>f <cmd>call python#addflag()<cr> 
nnoremap ts <cmd>call python#togglemember()<cr>
noremap mp <cmd>call python#run()<cr>
nnoremap dso <cmd>call python#deleteattribution()<cr>


if search('^#.\?.\?%%', 'ncW') > 0
    call python#notebooksetup()
endif

nnoremap <space>np :call jukit#convert#notebook_convert("jupyter-notebook")<cr>

command Notebook call python#notebooksetup()
command Denote exe "g/#.*|%%--%%| <.*|.*>/delete"|%!cat -s


nnoremap <buffer> <leader>a <cmd>call python#addargument()<cr>
nnoremap <buffer> <leader>m <cmd>call python#addmember()<cr>
nnoremap <buffer> <leader>i <cmd>call python#addimport()<cr>

call python#pythonsetup()

compiler python


