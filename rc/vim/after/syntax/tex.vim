
highlight TodoHead term=bold ctermfg=0 ctermbg=12 gui=bold guifg=#d33682 guibg=#073642
highlight TodoBody term=bold cterm=bold ctermbg=12 gui=bold guifg=#268bd2 guibg=#073642 guisp=#268bd2
exe "syn region regionTodoBody start=/".tex#comment_regex().'\(.*\[resolved:.*\]\)\@!\(\[.*\]\)\?{/ end=/}/ skipwhite contains=innerTodoBody,TodoHead'
syn region innerTodoBody start=/.{/ end=/}/ contains=innerTodoBody contained skipwhite skip=/\v\{/
exe "syn match TodoBody /".tex#comment_regex().'\(.*\[resolved:.*\]\)\@!\(\(\[.*\]\)\?{\)\@!.*$/ skipwhite contains=innerTodoBody'
exe 'syn match TodoHead /'.tex#comment_regex().'\(\[.*\]\)\?/ containedin=TodoBody contained skipwhite'
highlight link innerTodoBody TodoBody
highlight link regionTodoBody TodoBody
