command TODO call tex#comments()
command SLCOM call tex#comments('SL')

nmap <F9> <cmd>TODO<cr>
nmap <C-F9> <cmd>SLCOM<cr>

nmap <F3> tsD
nmap <F4> tsd
imap <F3> <C-O>tsD
imap <F4> <C-O>tsd

map <buffer> <space>X :silent! call tex#togmark()<cr>
map <buffer> <space>x :silent! call tex#togresolve()<cr>

vmap <buffer> <C-J> <esc>:call tex#nextcomment()<cr>mv:execute("norm! `<" . visualmode() . "`v")<cr>
vmap <buffer> <C-K> <esc>:call tex#prevcomment()<cr>mv:execute("norm! `<" . visualmode() . "`v")<cr>

nmap <buffer> <C-J> <cmd>call tex#nextcomment()<cr>
nmap <buffer> <C-K> <cmd>call tex#prevcomment()<cr>

nnoremap <buffer> <space>c o%%<C-R>=tex#stamp()<cr>:<space>
nnoremap <buffer> <space>C O%%<C-R>=tex#stamp()<cr>:<space>
vnoremap <buffer> <space>c :v/^\s*%%VM/v/^\s*$/norm I%%<C-R>=tex#stamp()<cr>:<space><esc>:noh<cr>
nnoremap <buffer> <space>r <cmd>silent! call tex#resolve()<cr>o% ^ <C-R>=tex#stamp()<cr>:<space>

nmap <buffer> <C-S>; <cmd>silent! wall<bar>call vimtex#compiler#start()<cr>
nmap <buffer> <C-S><C-E> <cmd>VimtexStopAll<cr>
imap <buffer> <C-S>; <C-O><cmd>silent! wall<bar>call vimtex#compiler#start()<cr>
nmap <buffer> <C-S>= <cmd>silent! w<cr><cmd>VimtexCompileSS<cr>

nmap <buffer> <C-S>' <cmd>silent! w<cr><cmd>call tex#view()<cr>
imap <buffer> <C-S>' <cmd>silent! w<cr><C-O><cmd>call tex#view()<cr>

set conceallevel=0
set expandtab
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


nmap <buffer> tsV <cmd>call tex#vertsub('Vert','\\\|')<cr>
nmap <buffer> tsv <cmd>call tex#vertsub('vert','\|')<cr>
nmap <buffer> <C-S><C-K> <cmd>call tex#viewer_layout(1)<cr>
nmap <buffer> <F5> <cmd>call tex#viewer_layout(1)<cr>
nmap <buffer> <F5> <cmd>call tex#viewer_layout(1)<cr>
map <buffer> <C-K> <cmd>call tex#viewer_layout(0)<cr>

" vmap <buffer> Sc <plug>(vimtex-cmd-create)
" function Cmdcreate(vis)
"     normal! `[v`]
"     let cmd = input('Command: ')
"     call vimtex#cmd#create(cmd, 'v')
" endfunction
" call operator#user#define('cmd-create', 'Cmdcreate')
" map ysc <plug>(operator-cmd-create)
" map yssc yscil
let b:surround_{char2nr('c')} = "\\\1command: \1{\r}"
let b:surround_{char2nr('u')} = "\\underbrace{\r}_{\\mathclap{\\text{\1text: \1}}}"
let b:surround_{char2nr('U')} = "\\underbrace{\r}_{\\mathclap{\1math: \1}}"
let b:surround_{char2nr('x')} = "e^{\r}"
let b:surround_{char2nr('m')} = "$\r$"


setlocal tags+=,/usr/local/texlive/2022/texmf-dist/tags

setlocal tw=170

" vmap Sm S$
nmap dsm ds$
nmap tsm ts$
" nmap yam ya$
" nmap yim yi$
" nmap ysim ysi$
" nmap ysam ysa$
let b:surround_{char2nr('m')} = "\$\r\$"
omap <buffer> im i$
omap <buffer> am a$
xmap <buffer> im i$
xmap <buffer> am a$

nmap dsx vax<esc>xxds}
nmap tsx vat<esc>xs\exp<esc>f{cs})

fun s:exponent()
    let start = getpos('.')
    if search('e\^{', 'bcW', line('.')-2) == 0
        return 0
    else
        let start = getpos('.')
        normal f{%
        let end = getpos('.')
    endif
    return ['v', start, end]
endfun

fun s:inexponent()
    let start = getpos('.')
    if search('e\^{\zs.', 'bcW', line('.')-2) == 0
        return 0
    else
        let start = getpos('.')
        normal F{%h
        let end = getpos('.')
    endif
    return ['v', start, end]
endfun


call textobj#user#plugin('tex', {
            \   'exp': {
            \     'select-i': 'ix',
            \     'select-a': 'ax',
            \     'select-a-function': 's:exponent',
            \     'select-i-function': 's:inexponent',
            \     'sfile': expand('<sfile>'),
            \   },
            \   'integral': {
            \     'select-a': 'aS',
            \     'select-i': 'iS',
            \     'pattern': ['\\int ', '\\d.\?\>'],
            \   }})

omap am a$
omap im i$
xmap am a$
xmap im i$

nmap <buffer> =a <cmd>call tex#movealign()<cr>



setlocal formatexpr=tex#sentencebreak(v:lnum,v:lnum+v:count-1)
nmap <buffer> <space>ks :call system('pkill Skim')<cr>

command Arxiv Dispatch arxiv
cabbrev arxiv Arxiv
let b:enable_spelunker_vim = 1
call spelunker#toggle#init_buffer(2, 1)

nmap mp <cmd>call tex#runpdf()<cr>
nmap mo <cmd>call tex#compilepdf()<cr>

call operator#user#define('percentify', 'tex#percentify')
map tp <plug>(operator-percentify)
nmap tpp tpil

call operator#user#define('breakcomma', 'tex#breakcomma')
map tc <plug>(operator-breakcomma)
nmap tcc tcil

imap <C-K> <C-O><cmd>call tex#align_cut()<cr>
imap <C-J> <C-O><cmd>call tex#align_newline()<cr>

command -nargs=* -bang Displays if <bang>0<bar>unlet g:tex_displays<bar>else<bar>let g:tex_displays=<q-args><bar>endif<bar>call tex#viewer_layout(0)

nmap <leader>i <cmd>call tex#addimport()<cr>
Alias disp Displays
nmap <C-\> :Make!<cr>

nmap gA :call tex#align()<cr>
nmap g<space> :retab<cr>gaae*<C-R>1<cr><C-L>1<cr><space>

command Abstract call tex#abstract()
command Title call tex#title()
Alias abstract Abstract
Alias title Title

command Cleverify g/^/exe 's/\(\.\s\+\)\@<!\(\<\k\+\)\.\?\(\~\|\s\)\\ref/\\cref/gce|s/\.\s\+\zs\(\<\k\+\)\.\?\~\\ref/\\Cref/gce'

Alias figs Figs

nmap <buffer> <F1> <cmd>call vimtex#qf#setqflist()<cr><cmd>copen<cr>

let g:ctrlp_extensions = get(g:, 'ctrlp_extensions', [])
            \ + ['spelunker']
