if search('python', 'nc') > -1
    compiler python
endif

if search('latexmk', 'nc') > -1
    " compiler tex
    nmap <buffer> <F1> <cmd>call vimtex#qf#setqflist()<cr><cmd>copen<cr>
endif
