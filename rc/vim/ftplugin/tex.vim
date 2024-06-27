command TODO call tex#comments()
command SLCOM call tex#comments('SL')

nmap <F9> <cmd>TODO<cr> 
nmap <C-F9> <cmd>SLCOM<cr>

nmap <F3> tsD
nmap <F4> tsd
imap <F3> <C-O>tsD
imap <F4> <C-O>tsd

map <buffer> <space>X :call tex#togmark()<cr>
map <buffer> <space>x :call tex#togresolve()<cr>

vmap ]c <esc>:call tex#nextcomment()<cr>mv:execute("norm! `<" . visualmode() . "`v")<cr>
vmap [c <esc>:call tex#prevcomment()<cr>mv:execute("norm! `<" . visualmode() . "`v")<cr>

nmap ]c <cmd>call tex#nextcomment()<cr>
nmap [c <cmd>call tex#prevcomment()<cr>

nnoremap <buffer> <space>c o%%<C-R>=tex#stamp()<cr>:<space>
nnoremap <buffer> <space>C O%%<C-R>=tex#stamp()<cr>:<space>
vnoremap <buffer> <space>c :v/^\s*%%VM/v/^\s*$/norm I%%<C-R>=tex#stamp()<cr>:<space><esc>:noh<cr>

nmap <buffer> <C-S>; <cmd>silent! wall<bar>call vimtex#compiler#start()<cr>
imap <buffer> <C-S>; <C-O><cmd>silent! wall<bar>call vimtex#compiler#start()<cr>
nmap <buffer> <C-S>= <cmd>silent! w<cr><cmd>VimtexCompileSS<cr>

nmap <buffer> <C-S>' <cmd>silent! w<cr><cmd>call tex#view()<cr>
imap <buffer> <C-S>' <cmd>silent! w<cr><C-O><cmd>call tex#view()<cr>

set spell
set wrap
set iskeyword+=-
set iskeyword+=@-@

nmap <buffer> <leader>d <cmd>call tex#gotodef()<cr>
nmap <buffer> <leader>D <cmd>call tex#showdef()<cr>

let g:latexdef_pack = [
            \'amssymb', 'amsfonts', 'amsmath', 'float', 'graphicx',
            \'hyperref', 'xcolor', 'enumitem', 'mathtools', 'siunitx', 'physics', 'cancel',
            \'algorithm', 'listings', 'subcaption', 'caption', 'tikz', 'cleveref', 
            \'tabularx', 'booktabs', 'multirow', 'array', 'tikz-cd', 'algpseudocode',
            \'fancyhdr', 'geometry', 'titlesec', 'natbib', 'standalone', 'pdfpages', 'xparse', 'etoolbox',
            \]

vmap Sx "sce^{<C-R>s}<esc>
nmap dsx ds}hhxx


augroup tex
    autocmd!
    highlight TodoHead term=bold ctermfg=0 ctermbg=12 gui=bold guifg=#d33682 guibg=#073642
    autocmd BufWinEnter *.tex let b:matchtodorest = matchadd('DiffText', tex#comment_regex().'\(.*\[resolved:.*\]\)\@!\zs.*$')
    autocmd BufWinLeave *.tex silent! call matchdelete(b:matchtodorest)
    autocmd BufWinEnter *.tex let b:matchtodo = matchadd('TodoHead', tex#comment_regex().'\(.*\[resolved:.*\]\)\@!')
    autocmd BufWinLeave *.tex silent! call matchdelete(b:matchtodo)
    autocmd BufWinEnter *.tex set conceallevel=0
augroup END


nmap <buffer> tsV <cmd>call tex#vertsub('Vert','\\\|')<cr>
nmap <buffer> tsv <cmd>call tex#vertsub('vert','\|')<cr>
nmap <buffer> <C-S><C-K> <cmd>call tex#resetviewer()<cr>
nmap <buffer> <C-S><C-A> <cmd>call tex#main()<cr>

vmap <buffer> Sc <plug>(vimtex-cmd-create)

nnoremap <buffer> <leader>ba <cmd>call bib#addref()<cr>
nnoremap <buffer> <leader>bo <cmd>call bib#open()<cr>
nnoremap <buffer> <leader>bc <cmd>call bib#copy()<cr>
nnoremap <buffer> <leader>bC <cmd>call bib#append()<cr>

set tags+=,/usr/local/texlive/2022/texmf-dist/tags
