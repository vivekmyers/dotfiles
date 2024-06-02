command TODO call tex#comments()
command SLCOM call tex#comments('SL')

nmap <F10> <cmd>TODO<cr> 
nmap <C-F10> <cmd>SLCOM<cr>

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

nmap <buffer> <C-S>' <cmd>silent! w<cr><plug>(vimtex-view)
imap <buffer> <C-S>' <C-O><cmd>silent! w<cr><C-O><plug>(vimtex-view)

set spell
set wrap
match DiffText '\(%.*\)\@<!%%[[:space:]]*[A-Z][A-Z]\(\.[0-9]*\)*:.*$'

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


nmap <buffer> tsV <cmd>call tex#vertsub('Vert','\\\|')<cr>
nmap <buffer> tsv <cmd>call tex#vertsub('vert','\|')<cr>
nmap <buffer> <C-S><C-K> <cmd>call tex#resetviewer()<cr>
nmap <buffer> <C-S><C-A> <cmd>call tex#main()<cr>

augroup tex
    autocmd!
    autocmd BufEnter *.tex set conceallevel=0
augroup END

vmap <buffer> Sc <plug>(vimtex-cmd-create)

nnoremap <buffer> <leader>ba <cmd>call bib#addref()<cr>
nnoremap <buffer> <leader>bo <cmd>call bib#open()<cr>
nnoremap <buffer> <leader>bc <cmd>call bib#copy()<cr>
nnoremap <buffer> <leader>bC <cmd>call bib#append()<cr>
