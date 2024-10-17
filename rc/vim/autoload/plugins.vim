"Plug 'rhysd/conflict-marker.vim'
let g:conflict_marker_common_ancestors = '^||||||| .*$'
let g:conflict_marker_separator = '^=======$'
let g:conflict_marker_begin = '^<<<<<<< .*$'
let g:conflict_marker_end   = '^>>>>>>> .*$'
if has("gui_running")
    augroup conflict
        autocmd!
        autocmd VimEnter * highlight ConflictMarkerBegin guibg=#2f7366
        autocmd VimEnter * highlight ConflictMarkerOurs guibg=#2e5049
        autocmd VimEnter * highlight ConflictMarkerTheirs guibg=#344f69
        autocmd VimEnter * highlight ConflictMarkerEnd guibg=#2f628e
        autocmd VimEnter * highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81
    augroup END
endif

"Plug 'junegunn/vim-plug'
nnoremap <leader>pi <cmd>PlugInstall<cr>

" Plug 'vim-scripts/scratch.vim'
"     nmap <space>s <cmd>Scratch<cr>
"     nmap <space>S <cmd>Sscratch<cr>
"Plug 'mtth/scratch.vim'
nmap <space>s <cmd>Scratch<cr>
nmap <space>S <cmd>ScratchInsert<cr>
function! Scratch()
    vnew
    wincmd L
    noswapfile hide enew
    setlocal buftype=nofile
    setlocal bufhidden=hide
    "setlocal nobuflisted
    "lcd ~
endfunction
nmap ,s <cmd>call Scratch()<cr>
let g:scratch_autohide = 0

"Plug 'zenbro/mirror.vim'
" let g:mirror#spawn_command = ':Zsh '


" augroup mirror
"     autocmd!
"     au VimEnter * Alias mcon MirrorConfig
"     au VimEnter * Alias menv MirrorEnvironment!
"     au VimEnter * Alias ssh MirrorSSH
"     au VimEnter * Alias mps MirrorPush
"     au VimEnter * Alias mpl MirrorPull
"     au VimEnter * Alias mdiff MirrorDiff
"     au VimEnter * Alias medit MirrorEdit
" augroup END
"

"Plug 'trapd00r/vim-syntax-vidir-ls'
"Plug 'kana/vim-textobj-line'

"Plug 'c0r73x/vimdir.vim'
nmap ,d <cmd>call utils#dircmd('Vimdir')<cr>
nmap ,D <cmd>call utils#dircmd('VimdirR')<cr>
let g:vimdir_force = 1

"Plug 'mbbill/undotree'
nnoremap <leader>u :UndotreeToggle<cr>


"Plug 'joom/latex-unicoder.vim'
let g:unicoder_cancel_normal = 1
let g:unicoder_cancel_insert = 1
let g:unicoder_cancel_visual = 1
nnoremap <C-u> :call unicoder#start(0)<CR>
inoremap <C-u> <space><esc>:call unicoder#start(1)<CR>
vnoremap <C-u> :<C-u>call unicoder#selection()<CR>
let g:unicode_map = {
            \ "\\i" : "ı"
            \ }


"Plug 'wellle/targets.vim'
autocmd User targets#mappings#user call targets#mappings#extend({
            \ 'a': {'argument': [{'o': '[([{]', 'c': '[])}]', 's': ','}]},
            \ })

"Plug 'mhinz/vim-grepper'
augroup grepper
    autocmd!
    autocmd VimEnter * let g:grepper.operator.highlight = 1
    autocmd VimEnter * let g:grepper.operator.tool = 'git'
    autocmd VimEnter * let g:grepper.operator.grepprg = 'git grep -niI "$*"'
augroup END
vmap <F12> <plug>(GrepperOperator)
nmap <F12> <cmd>Grepper -highlight -tool git -grepprg git grep -niI "$*"<cr>
" nmap <C-F12> <cmd>exe 'Grepper -highlight -tool git -grepprg git grep -niI -- "$*" <bar> grep -E '.shellescape('^[^:]*'.expand("%:e").':')<cr>
nmap <F11> <cmd>Grepper -highlight -tool git -grepprg grepfiles "$*"<cr>
" vmap <C-F12> y:Grepper -noprompt -highlight -tool git -grepprg git grep -nIF -- <C-R>=shellescape(@")<cr><bar>grep -E <C-R>=shellescape('^[^:]*'.expand("%:e").':')<cr><CR>
fun s:grepsetup()
    let g:grepper.tools += ['git']
    " let g:grepper.git = {
    "     \ 'grepprg':    'git grep -nI',
    "     \ 'grepformat': '%f:%l:%m',
    "     \ 'escape':     '\^$.*[]"',
    "     \ }
endfun
autocmd VimEnter * call <sid>grepsetup()



" Plug 'airblade/vim-gitgutter'
" git@github.com:moll/vim-bbye.git
"Plug 'moll/vim-bbye'
nnoremap <leader>q <cmd>w<cr>:Bdelete<cr>
nnoremap <leader>Q :Bdelete!<cr>
nnoremap <F6> :qall!<cr>
imap <F6> <esc>:qall!<cr>
nnoremap <F7> :Bwipeout!<cr>
imap <F7> <esc>:Bwipeout!<cr>
tnoremap <F7> <C-\><C-n>:Bwipeout!<cr>
tnoremap <F6> <C-\><C-n>:qall!<cr>


"Plug 'tpope/vim-surround'
"Plug 'tpope/vim-rhubarb'
"Plug 'tpope/vim-fugitive'
nnoremap <leader>g :G
" nnoremap <leader>s <cmd>vert G<cr>
" nnoremap <leader>S <cmd>G<cr>
nnoremap <space>ac :Autocommit<cr>
nnoremap <space>ga :Git add %:p<cr><cr>
nnoremap <space>gs :vert Git<cr>
nnoremap <space>gc :Git commit -v -q<cr>
nnoremap <space>gC :Git commit --amend -v -q<cr>
nnoremap <space>gt :Git commit -v -q %:p<cr>
nnoremap <space>gd :Gvdiffsplit<cr>
nnoremap <space>gD :Gvdiffsplit<cr>:windo set wrap<cr>
nnoremap <space>gv :Gvdiffsplit<space>
nnoremap <space>gk :Git blame<cr>
nnoremap <space>ge :Gedit<cr>
nnoremap <space>gr :Gread<cr>
nnoremap <space>gw :Gwrite<cr>
nnoremap <space>gl :vert silent! Git log<cr>
nnoremap <space>gp :Ggrep<space>
nnoremap <space>gm :GMove<space>
" nnoremap <space>gb :Git branch<Space>
nnoremap <space>go :Git checkout<space>
nnoremap <space>gps :Dispatch! git push<cr>
nnoremap <space>gpl :Dispatch! git pull<cr>
map <space>gb :GBrowse!<cr>
map <space>gB :GBrowse<cr>
nnoremap <space>gh :.Gclog<cr>
nnoremap <space>gH :0Gclog<cr>
nnoremap <space>g<space> :G<space>
nnoremap <space>v<space> :vert G<space>
nnoremap <space>gf :Dispatch! git fetch --all<cr>

function s:gitgraph()
    let obj = fugitive#Object()
    vert Git log --graph --oneline --all --decorate

    nmap <buffer> ) :call search('^[<bar> *]*\zs[a-z0-9]\+','W')<cr>
    nmap <buffer> ( :call search('^[<bar> *]*\zs[a-z0-9]\+','Wb')<cr>

    if obj =~ '^[a-z0-9]\+\(:.*\)\?$'
        call search(obj[:6], 'w')
        exe '3match gitDiffAdded /^[| *]*\zs\(' . obj[:6] . '\)[a-z0-9]*/'
    else
        call search('^[| *]*\zs[a-z0-9]\+','W')
        let modified = systemlist('git log --all --follow --pretty=format:"%h" -- '.shellescape(obj))->join('\|')
        exe '3match gitDiffAdded /^[| *]*\zs\(' . modified . '\)/'
    endif
    2match gitcommitBranch /^[| *]*[a-z0-9]* \zs([^)]*)/

endfunction
nnoremap <space>gg <cmd>call <sid>gitgraph()<cr>

fun s:autocommit()
    G add -u
    vert G commit
    if bufname('%') =~ 'COMMIT_EDITMSG'
        call utils#generate_commit_message()
        %perldo s/^\s*"|"\s*$//g
        " exe "normal /^#\<cr>kk"
        "     if line('.') > 1
        "         delete
        "     endif
        "     exe "normal! gg"
        " noh
    endif
endfun

command! Autocommit call s:autocommit()
" autocmd User FugitiveIndex nnoremap <buffer> <leader>p :Git push<cr>
" autocmd User FugitiveIndex nnoremap <buffer> <leader>u :Git pull<cr>

"Plug 'machakann/vim-Verdin'

"Plug 'tpope/vim-unimpaired'
"Plug 'tpope/vim-commentary'
"Plug 'tpope/vim-repeat'
"Plug 'tpope/vim-sensible'
"Plug 'tpope/vim-vinegar'
"Plug 'tpope/vim-eunuch'
"Plug 'tpope/vim-dispatch'
"Plug 'tpope/vim-tbone'

nnoremap <space>t :Tmux<space>
nnoremap <F5> <cmd>call utils#leftview()<cr>
tnoremap <F5> <C-W>:call utils#leftview()<cr>
fun! OpTwriteRight(motion)
    exe "'[,']Twrite right"
endfun

call operator#user#define('twriteright', 'OpTwriteRight')
map g> <plug>(operator-twriteright)
nmap g>> g>g>

"Plug 'michaeljsmith/vim-indent-object'
"Plug 'schickling/vim-bufonly'
nmap <C-F2> <cmd>BufOnly<cr><C-L><cmd>AirlineRefresh<cr>

"Plug 'ludovicchabant/vim-gutentags'
let g:gutentags_cache_dir = '~/.cache/tags'
let g:gutentags_project_root = ['.git', '.hg', '.svn', '.bzr', '_darcs', '.root', '.cenv', '.env']
let g:gutentags_ctags_tagfile = '.tags'
let g:gutentags_ctags_extra_args = [
            \'--fields=+l', '--fields=+d', '--options=' . $HOME . '/.ctags',
            \]
let g:gutentags_generate_on_new = 1
let g:gutentags_generate_on_missing = 1
let g:gutentags_generate_on_write = 1
let g:gutentags_generate_on_empty_buffer = 0
command! -nargs=0 GutentagsClearCache call system('rm ' . g:gutentags_cache_dir . '/*')


"Plug 'scrooloose/nerdtree'
let g:NERDTreeHijackNetrw=0
"Plug 'PhilRunninger/nerdtree-visual-selection'

"Plug 'justinmk/vim-gtfo'
nnoremap gop <cmd>call gtfo#open#file(b:vimtex.viewer.out())<cr>
let g:gtfo#terminals = { 'mac': 'iterm' }


"Plug 'rafi/awesome-vim-colorschemes'

"Plug 'tommcdo/vim-exchange'


" Plug 'ubaldot/vim-outline'
"     nmap <silent> <space>O <Plug>OutlineRefresh
"     nmap <silent> <space>o <Plug>OutlineGoToOutline
"Plug 'preservim/tagbar'
nmap <F8> <cmd>TagbarOpen j<cr>
nnoremap ]j <cmd>call tagbar#jumpToNearbyTag(1)<cr>
nnoremap [j <cmd>call tagbar#jumpToNearbyTag(-1)<cr>


" Plug 'ubaldot/vim-replica'
"Plug 'luk400/vim-jukit'
let g:jukit_terminal = 'vimterm'
let g:jukit_mpl_block = 0
let g:jukit_convert_overwrite_default = 1
let g:jukit_hl_extensions=['py']
let g:jukit_mappings = 0
let g:jukit_max_size = 100

if exists('$TMUX')
    let g:jukit_terminal = 'tmux'
    let g:jukit_inline_plotting=1
endif

if exists('$KITTY_WINDOW_ID')
    let g:jukit_terminal = 'kitty'
endif

nnoremap <C-S><C-J> <cmd>call python#notebooksetup()<cr>

" let g:jukit_auto_output_hist = 1

"Plug 'kana/vim-textobj-user'

" Plug 'GCBallesteros/vim-textobj-hydrogen'
" Plug 'goerz/jupytext.vim'
"     let g:jupytext_fmt = 'py:percent'

" Plug 'ubaldot/vim-conda-activate', { 'on': 'CondaActivate' }
"     map <leader>ca <cmd>CondaActivate<cr>

"Plug 'vivekmyers/vim-conda', { 'on': ['CondaChangeEnv', 'CondaActivate'] }
map <leader>ca <cmd>CondaChangeEnv<cr>
map <leader>ce :CondaActivate<space>
map <leader>ci <cmd>Conda info<cr>
command! -nargs=? Conda exe "Dispatch " . $CONDA_EXE . ' ' . <q-args>
command! -nargs=? Pip exe "Dispatch " . $CONDA_EXE . ' run -n ' . $CONDA_DEFAULT_ENV . ' pip ' . <q-args>
command! -nargs=? Pipreq e environment.yml|exe "Dispatch zsh -c pipreq\\ " . <q-args>|e
command! -nargs=? Creq e environment.yml|exe "Dispatch zsh -ic creq\\ " . <q-args>|e
let $ENVNAME = $CONDA_DEFAULT_ENV
augroup conda
    autocmd!
    au VimEnter * Alias conda Conda
    au VimEnter * Alias pip Pip
    au VimEnter * Alias pipreq Pipreq
    au VimEnter * Alias creq Creq
    au DirChanged,VimEnter * let g:jukit_shell_cmd = 'load condalib && conda activate '.$ENVNAME.' && PYTHONBREAKPOINT=ipdb.set_trace ipython '
    au BufEnter *.py let g:jukit_shell_cmd = 'load condalib && conda activate '.$ENVNAME.' && PYTHONBREAKPOINT=ipdb.set_trace ipython '
augroup END
" let g:conda_startup_msg_suppress = 1
" let g:conda_startup_wrn_suppress = 1

"Plug 'junegunn/vim-easy-align'
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

"Plug 'davidhalter/jedi-vim'
let g:jedi#goto_stubs_command = ""
let g:jedi#goto_assignments_command = ""
let g:jedi#popup_on_dot = 0

"Plug 'gioele/vim-autoswap'
" let g:autoswap_detect_tmux = 1

"Plug 'airblade/vim-rooter'
let g:rooter_patterns = ['Makefile', '.git', '.hg', '.svn', '.bzr', '_darcs', '.root']
let g:rooter_patterns += ['>Overleaf', '>Documents', '>research', '>Documents/code', '>papers']

"Plug 'lervag/vimtex'
let g:tex_flavor = 'latex'
let g:vimtex_quickfix_mode = 0
let g:vimtex_complete_ignore_case = 1
let g:vimtex_complete_smart_case = 1
if has('unix')
    if has('mac')
        let g:vimtex_view_method = "skim"
        let g:vimtex_view_general_viewer
                    \ = '/Applications/Skim.app/Contents/SharedSupport/displayline'
        let g:vimtex_view_general_options = '-r @line @pdf @tex'
        let g:vimtex_view_sync_method = "skim"
    else
        let g:latex_view_general_viewer = "zathura"
        let g:vimtex_view_method = "zathura"
    endif
elseif has('win32')
endif
let g:vimtex_quickfix_open_on_warning = 0
let g:vimtex_quickfix_mode = 2
if has('nvim')
    let g:vimtex_compiler_progname = 'nvr'
endif
let g:vimtex_quickfix_ignore_filters = ['Underfull', 'Overfull', 'Tight', 'space']
let g:vimtex_matchparen_enabled = 0

" enable shell escape
let g:vimtex_compiler_latexmk = {
            \ 'aux_dir': 'build',
            \ 'out_dir': 'build',
            \ 'options': [
            \   '-use-make',
            \   '-shell-escape',
            \   '-file-line-error',
            \   '-synctex=1',
            \   '-interaction=nonstopmode',
            \ ],
            \}

let g:vimtex_delim_toggle_mod_list = [
            \ ['\bigl', '\bigr'],
            \ ['\Bigl', '\Bigr'],
            \ ['\biggl', '\biggr'],
            \ ['\Biggl', '\Biggr'],
            \]
let g:vimtex_toggle_fractions = {
            \ 'INLINE': 'frac',
            \ 'frac': 'INLINE',
            \ 'dfrac': 'tfrac',
            \ 'tfrac': 'dfrac',
            \}

"Plug 'honza/vim-snippets'

" Plug 'KeitaNakamura/tex-conceal.vim'
"     set conceallevel=0
"     let g:tex_conceal=''
"     hi Conceal ctermbg=none

"Plug 'psf/black', { 'branch': 'stable' }
nnoremap <leader>bl :Black<cr>

" Plug 'haya14busa/vim-easyoperator-phrase'
" Plug 'haya14busa/vim-easyoperator-line'

"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
let g:airline_theme='violet'
let g:airline_solarized_bg='dark'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_extensions = ['tabline', 'branch', 'grepper', 'netrw', 'gutentags', 'vimtex', 'quickfix', 'searchcount', 'whitespace', 'wordcount', 'ale']
let g:airline_section_z = airline#section#create_left(['%{$ENVNAME}'])
" let g:airline_extensions = ['tabline', 'ale', 'branch', 'grepper',
"     'gutentags', 'netrw', 'quickfix', 'searchcount', 'whitespace',
"     'wordcount']
let g:airline_experimental=1
let g:airline_highlighting_cache = 1

let g:asyncrun_status = ''
let g:asyncrun_icons = {
    \ 'running': 'running',
    \ 'success': '',
    \ 'failure': 'failure',
    \ 'stopped': '',
    \ }
let g:airline_section_warning = airline#section#create_right(['%{g:asyncrun_icons[g:asyncrun_status]}'])


"Plug 'yegappan/mru'
" nmap <leader>o <cmd>MRU<cr>
" nmap <leader><leader>o :MRU<space>
" let g:MRU_FuzzyMatch = 0

"Plug 'jlanzarotta/bufexplorer'

"Plug 'dense-analysis/ale'
let g:ale_linters = {
            \   'python': ['pylint'],
            \   'html': ['htmlhint', 'tidy'],
            \   'tex': ['latexindent'],
            \   'bib': [],
            \   'yml': ['prettier'],
            \   'css': ['csslint'],
            \}
let g:ale_fixers = {
            \   'python': ['black', 'autoimport', 'remove_trailing_lines', 'trim_whitespace', 'autoflake'],
            \   'tex': ['latexindent'],
            \   'html': ['remove_trailing_lines', 'trim_whitespace', 'prettier'],
            \   'bib': [],
            \   'yml': ['prettier'],
            \   'css': ['prettier'],
            \}
let g:ale_html_tidy_executable = '/usr/local/bin/tidy'
let g:ale_html_tidy_options = '-mi -xml -wrap 0 %c -mi -xml -wrap'
let g:ale_python_flake8_options = '--max-line-length=120'
let g:ale_python_black_options = '--line-length=120'
let g:ale_python_pylint_options = '--disable=C,R,E1136,E0015,C0116,W0311,W0640,W0108'

let g:ale_tex_latexindent_options = '-c=.build/'
nmap <space>at <cmd>ALEToggle<cr>
nmap <space>ai <cmd>ALEInfo<cr>
" nmap <C-H> :ALEFix<cr>
nmap <silent> <C-K> <plug>(ale_previous_wrap)
nmap <silent> <C-J> <plug>(ale_next_wrap)
let g:ale_fixers['*'] = ['remove_trailing_lines', 'trim_whitespace']

"Plug 'jeetsukumaran/vim-pythonsense'
" Plug 'jupyter-vim/jupyter-vim'
"Plug 'sillybun/vim-repl'


"Plug 'altercation/vim-colors-solarized'
"Plug 'alvan/vim-closetag'

"Plug 'sirver/ultisnips'
let g:UltiSnipsExpandTrigger = '<C-A>'
let g:UltiSnipsJumpForwardTrigger = '<C-A>'
let g:UltiSnipsJumpBackwardTrigger = '<C-O>'

"Plug 'github/copilot.vim'
" imap <C-\><C-L> <Plug>(copilot-suggest)<Plug>(copilot-accept-line)
" imap <C-\><C-W> <Plug>(copilot-suggest)<Plug>(copilot-accept-word)
" imap <C-\><C-N> <Plug>(copilot-suggest)<Plug>(copilot-next)
" imap <silent><script><expr> <C-\><C-\> copilot#Accept("")
imap <C-\> <Plug>(copilot-suggest)<Plug>(copilot-accept-word)

"Plug 'Matt-A-Bennett/vim-surround-funk'

" Plug 'altercation/vim-colors-solarized'
" Plug 'alvan/vim-closetag'

" Plug 'vim-scripts/cmdalias.vim'
" Plug 'dohsimpson/vim-macroeditor'
" Plug 'tommcdo/vim-express'

vmap <silent> <C-T> <Plug>TranslateRV
let g:translator_target_lang = 'en'
let g:translator_source_lang = 'zh-CN'

let g:csv_arrange_align = 'rl*'
let g:csv_default_delimiter = ' '

let g:projectionist_heuristics = {
            \   'autoload/&ftplugin/': {
            \       "autoload/load.vim": {"alternate": "autoload/plugins.vim"},
            \       "autoload/plugins.vim": {"alternate": "autoload/load.vim"},
            \       "plugin/*.vim": {"type": "vim"},
            \       "ftplugin/*.vim": {"type": "vim", "alternate": "autoload/{}.vim"},
            \       "autoload/*.vim": {"type": "vim", "alternate": "ftplugin/{}.vim"},
            \   },
            \  '*.tex&makefile': {
            \       "README.md": {"type": "doc"},
            \       "*.py": {"type": "script"},
            \       "*.sh": {"type": "script"},
            \       "*.zsh": {"type": "script"},
            \       "*.vim": {"type": "vim"},
            \       "*.yml": {"type": "config"},
            \       "*.json": {"type": "config"},
            \       "*.conf": {"type": "config"},
            \       "scripts/*": {"type": "script"},
            \       "*.tex": {"type": "tex", "alternate": "build/{}.pdf", "path": ['build', 'figures', 'data', 'scripts']},
            \       "*.sty": {"type": "tex"},
            \       "*.cls": {"type": "tex"},
            \       "*.pdf": {"type": "pdf", "alternate": "{}.tex"},
            \       "makefile": {"type": "make"},
            \   },
            \   '*.html': {
            \       "README.md": {"type": "doc"},
            \       "*.html": {"type": "html", "alternate": "{}.css"},
            \       "*.css": {"type": "css", "alternate": "{}.html"},
            \       "*.js": {"type": "js", "related": "*.html"},
            \       "*.json": {"type": "config"},
            \       "*.yml": {"type": "config"},
            \       "makefile": {"type": "make"},
            \   },
            \   '*.py|*.ipynb': {
            \       "README.md": {"type": "doc"},
            \       "*.py": {"type": "script", "alternate": "{}.ipynb"},
            \       "*.sh": {"type": "script"},
            \       "*.ipynb": {"type": "notebook", "alternate": "{}.py"},
            \       "makefile": {"type": "make"},
            \   },
            \   'config/bin/': {
            \       "config/bin/*": {"type": "script", "alternate": ".local/bin/{}", "template": ["#!/bin/bash", ""]},
            \       "config/functions/*": {"type": "script", "alternate": "config/completions/{}", "template": ["#!/bin/zsh", ""]},
            \       "config/completions/*.zsh": {"type": "script", "alternate": "config/functions/{}.zsh", "template": ["#compdef {}", ""]},
            \   },
            \   '.local/bin/': {
            \       ".local/bin/*": {"type": "script", "alternate": "config/bin/{}", "template": ["#!/bin/bash", ""]},
            \   },
            \   '.omz/functions/': {
            \       ".omz/functions/*": {"type": "script", "alternate": "config/functions/{}.zsh", "template": ["#!/bin/zsh", ""]},
            \   },
            \   '*' : {
            \       "README.md": {"type": "doc"},
            \       "*.py": {"type": "script"},
            \       "*.sh": {"type": "script"},
            \       "*.zsh": {"type": "script"},
            \       "*.vim": {"type": "vim"},
            \       "*.yml": {"type": "config"},
            \       "*.json": {"type": "config"},
            \       "bin/*": {"type": "script"},
            \       ".sync": {"type": "script", "filetype": "zsh", "template": [
            \           "#!/bin/zsh", "RUSER=$USER", "RPATH='~'", "HOST=", "",
            \           'if [ "upload" == $1 ];then', '    zsh -ic "rsync -avzu `dirname $0`/$2/$3 $RUSER@$HOST:$RPATH/$2/"',
            \           'elif [ "download" == $1 ];then', '     zsh -ic "rsync -avzu $RUSER@$HOST:$RPATH/$2/$3 `dirname $0`/$2/$3"',
            \           'fi']},
            \   },
            \}

nmap <space>e :E
nmap <space>a <cmd>A<cr>

" Plug 'kamykn/spelunker.vim'
let g:enable_spelunker_vim = 0
let g:spelunker_highlight_type = 2
let g:spelunker_disable_uri_checking = 1
let g:spelunker_disable_account_name_checking = 1
let g:spelunker_disable_email_checking = 1
let g:spelunker_disable_acronym_checking = 1
let g:spelunker_disable_backquoted_checking = 1

nmap z= <Plug>(spelunker-correct-all-from-list)
nmap zg <Plug>(add-spelunker-good-nmap)
nmap zw <Plug>(add-spelunker-bad-nmap)
nmap zG :SpelunkerAddAll<cr>


nmap ]s <Plug>(spelunker-jump-next)
nmap [s <Plug>(spelunker-jump-prev)

" Plug 'psliwka/vim-dirtytalk', { 'do': ':DirtytalkUpdate' }
set spelllang=en,programming


" Plug 'vim-autoformat/vim-autoformat'
nmap <C-H> :Autoformat<cr>
set formatexpr=Autoformat
let g:formatters_python = ['black']
let g:formatters_html = ['prettier']
let g:formatters_yml = ['prettier']
let g:formatters_css = ['prettier']


map <leader>o :CtrlPMRUFiles<cr>
augroup pluginExtra
    autocmd!
    fun s:unwarn()
        fun! csv#Warn(...)
        endfun
    endfun
    autocmd VimEnter * call <sid>unwarn()
    autocmd VimEnter * map <c-p> :CtrlPMixed<cr>
augroup END

" vmap <silent> <C-\> <Plug>(chatgpt-menu)
fun s:pythondep(name, ...)
    if a:0 == 0
        let pkg = a:name
    elseif a:1 == 1
        let pkg = a:name . "==". a:1
    else
        echoerr 'Invalid number of arguments'
        return
    endif
    au VimEnter * ++once $"silent! Dispatch! /usr/bin/python3 -c 'import {a:name}' 2>/dev/null || /usr/bin/python3 -m pip install {pkg} --user"
endfun
" let g:chat_gpt_split_direction = 'vertical'
"

call s:pythondep('openai', '1.6.1')

"
"Plug 'CoderCookE/vim-chatgpt'
"
""Plug 'madox2/vim-ai'
let g:ai_prompt = 'System: You are going to play a role of a completion engine, and will usually be asked to complete code, but may occassionally be asked to generate text or provide an explanation or other assistance. If you are outputting code, never include any english except valid syntax for the programming language. Do not include any commentary or surrounding text answer as concisely as possible.'

fun s:insertai()
    call inputsave()
    let prompt = input('Prompt: ')
    call inputrestore()
    exe ".-20,.AI " . g:ai_prompt . "\nTask:" . prompt
    startinsert
endfun

inoremap <C-G> <esc>:call <sid>insertai()<cr>
function AIOp(motion)
    call inputsave()
    let response = input('Prompt: ')
    call inputrestore()
    let prompt = g:ai_prompt . "\nTask:" . response
    exe "'[-20,']AI '" . prompt . "'"
endfunction
call operator#user#define('ai', 'AIOp')
map gai <plug>(operator-ai)
map gaii gaigai


let g:fixup_msg = 'System: Fix errors in this code block. If the input doesn''t seem like code, just fix spelling errors in the text. Do not output any commentary or content that is not a direct fix, if there is nothing to change leave the content unmodified. If you are outputting code, never output any english except valid syntax for the programming language. The context specified above is not part of the code block, but rather the code right before it; do not include or modify it in the output.'
" nnoremap gif :AIEdit fix grammar and spelling<CR>
function FixupOp(motion)
    let context = getline(max([0,line("'[")-50]), line("'["))
    " let context = context->map({_, v -> '(context) > '.v})
    let context = 'Context before the code to fix: """' . "\n" . context->join("\n") . '"""' . "\n"
    let prompt = g:fixup_msg . "\n" . context
    exe "'[,']AIEdit '" . prompt . "'"
endfunction

call operator#user#define('fixup', 'FixupOp')
map gif <plug>(operator-fixup)
map giff gifgif

function EditOp(motion)
    call feedkeys('`[v`]:AIEdit ', 'n')
endfunction

call operator#user#define('edit', 'EditOp')
map gie <plug>(operator-edit)
map giee giegie

xnoremap gic :AIChat<CR>
nnoremap gic :AIChat<CR>


nnoremap gir :AIRedo<CR>


let initial_prompt =<< trim END
    >>> system

    You are going to play a role of a completion engine with following parameters:
    Task: Provide compact code/text completion, generation, transformation or explanation
    Topic: general programming and text editing
    Style: Plain and concise result without any commentary, unless commentary is necessary
    Audience: Users of text editor and programmers that need to transform/generate text
    Code: Do not surround in backticks or any markdown, just provide the code content
END

let chat_engine_config = {
            \  "engine": "chat",
            \  "options": {
            \    "model": "gpt-4o",
            \    "endpoint_url": "https://api.openai.com/v1/chat/completions",
            \    "max_tokens": 0,
            \    "temperature": 0.1,
            \    "request_timeout": 20,
            \    "selection_boundary": "",
            \    "initial_prompt": initial_prompt,
            \  },
            \}

let g:vim_ai_complete = chat_engine_config
let g:vim_ai_edit = chat_engine_config

"Plug 'rafaqz/citation.vim'
"
""Plug 'Shougo/unite.vim'

let g:formatdef_latexindent = '"latexindent -"'

"Plug 'ojroques/vim-oscyank'
"

"Plug 'tpope/vim-sleuth'
let g:sleuth_tex_heuristics = 0

"Plug 'acarapetis/vim-sh-heredoc-highlighting'
let g:heredocs = {"SQL": "sql", "EXPECT": "expect", "HTML": "html", "RUST": "rust", "JSON": "json"}

""Plug 'eshion/vim-sync'
let g:sync_exe_filenames = '.sync'
nnoremap <space>su <cmd>call SyncUploadFile()<cr><cmd>redraw!<cr><cmd>copen<cr>
nnoremap <space>sd <cmd>call SyncDownloadFile()<cr><cmd>!<cr>
nnoremap <space>mps <cmd>copen<bar>wincmd p<cr><cmd>AsyncRun -post=cclose bash .sync upload .<cr>
nnoremap <space>mpl <cmd>copen<bar>wincmd p<cr><cmd>AsyncRun -post=cclose bash .sync download .<cr>
command! -nargs=0 VS :edit .sync

"Plug 'skywind3000/asyncrun.vim'
let g:asyncrun_status = "stopped"
augroup QuickfixStatus
    au! BufWinEnter quickfix setlocal
                \ statusline=%t\ [%{g:asyncrun_status}]\ %{exists('w:quickfix_title')?\ '\ '.w:quickfix_title\ :\ ''}\ %=%-15(%l,%c%V%)\ %P
augroup END
command! -bang -bar -nargs=* Gpush execute 'AsyncRun<bang> -cwd=' .
            \ fnameescape(FugitiveGitDir()) 'git push' <q-args>
command! -bang -bar -nargs=* Gfetch execute 'AsyncRun<bang> -cwd=' .
            \ fnameescape(FugitiveGitDir()) 'git fetch' <q-args>
"
""Plug 'christoomey/vim-tmux-navigator'

"Plug 'Vimjas/vint'
