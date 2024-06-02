
if has("nvim")
    if empty(glob('~/.config/nvim/autoload/plug.vim'))
        silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
                    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        autocmd VimEnter * call PlugInstall
    endif
else
    if empty(glob('~/.vim/autoload/plug.vim'))
        silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    endif
endif

if has('nvim')
    call plug#begin('~/.config/nvim/plug.vim')
else
    call plug#begin('~/.vim/plug.vim')
endif

Plug 'rhysd/conflict-marker.vim'
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

Plug 'junegunn/vim-plug'
    nnoremap <leader>pi <cmd>PlugInstall<cr>

Plug 'mbbill/undotree'


Plug 'wellle/targets.vim'
Plug 'mhinz/vim-grepper'
    vmap <F12> <plug>(GrepperOperator)
    nmap <F12> <cmd>Grepper -highlight -tool git -grepprg git grep -niI '$*'<cr>
    nmap <F11> <cmd>Grepper -highlight -tool git -grepprg git ls-files \| grep -i '$*'<cr>

Plug 'tpope/vim-surround'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-fugitive'
    nnoremap <leader>g :G
    " nnoremap <leader>s <cmd>vert G<cr>
    " nnoremap <leader>S <cmd>G<cr>
    nnoremap <space>ac :exe 'Dispatch! git commit -am ' . shellescape(system("autocommit"))<cr>
    nnoremap <space>ga :Git add %:p<CR><CR>
    nnoremap <space>gs :vert Git<CR>
    nnoremap <space>gc :Git commit -v -q<CR>
    nnoremap <space>gt :Git commit -v -q %:p<CR>
    nnoremap <space>gd :vert Gdiff<CR>
    nnoremap <space>gD :vert Gdiff<space>
    nnoremap <space>gk :G blame<CR>
    nnoremap <space>ge :Gedit<CR>
    nnoremap <space>gr :Gread<CR>
    nnoremap <space>gw :Gwrite<CR><CR>
    nnoremap <space>gl :vert silent! Git log<CR>
    nnoremap <space>gp :Ggrep<Space>
    nnoremap <space>gm :GMove<Space>
    " nnoremap <space>gb :Git branch<Space>
    nnoremap <space>go :Git checkout<Space>
    nnoremap <space>gps :Dispatch! git push<CR>
    nnoremap <space>gpl :Dispatch! git pull<CR>
    map <space>gb :GBrowse!<CR>
    map <space>gB :GBrowse<CR>
    nnoremap <space>gh :.Gclog<CR>
    nnoremap <space>gH :0Gclog<CR>
    nnoremap <space>g<space> :G<Space>
    nnoremap <space>v<space> :vert G<Space>
    " autocmd User FugitiveIndex nnoremap <buffer> <leader>p :Git push<cr>
    " autocmd User FugitiveIndex nnoremap <buffer> <leader>u :Git pull<cr>

Plug 'machakann/vim-Verdin'

Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-tbone'

Plug 'michaeljsmith/vim-indent-object'
Plug 'asheq/close-buffers.vim'
    nmap <C-S>\ <cmd>Bdelete other<cr><C-L>

Plug 'ludovicchabant/vim-gutentags'
    let g:gutentags_cache_dir = '~/.cache/tags'
    let g:gutentags_project_root = ['.git', '.hg', '.svn', '.bzr', '_darcs', '.root', '.build', '.cenv', '.env']
    let g:gutentags_ctags_tagfile = '.tags'
    let g:gutentags_ctags_extra_args = [
                \'--fields=+l', '--fields=+d', '--options=' . $HOME . '/.ctags',
                \]
    let g:gutentags_generate_on_new = 1
    let g:gutentags_generate_on_missing = 1
    let g:gutentags_generate_on_write = 1
    let g:gutentags_generate_on_empty_buffer = 0
    command! -nargs=0 GutentagsClearCache call system('rm ' . g:gutentags_cache_dir . '/*')


Plug 'scrooloose/nerdtree'
Plug 'PhilRunninger/nerdtree-visual-selection'

Plug 'justinmk/vim-gtfo'
    nnoremap gop <cmd>call gtfo#open#file(b:vimtex.viewer.out())<cr>
    let g:gtfo#terminals = { 'mac': 'iterm' }


Plug 'rafi/awesome-vim-colorschemes'

Plug 'tommcdo/vim-exchange'


Plug 'ubaldot/vim-replica'
    nmap <F3> <cmd>silent! ReplicaConsoleToggle<cr>
    nmap <F4> <cmd>silent! ReplicaConsoleShutoff<cr>
    nmap <F9> <cmd>ReplicaSendLines<cr>
    xmap <F9> <cmd>ReplicaSendLines<cr>
    nmap <F5> <cmd>ReplicaSendFile<cr>
    nmap <c-enter> <cmd>silent! ReplicaSendCell<cr>j

Plug 'goerz/jupytext.vim'
    let g:jupytext_fmt = 'py:percent'

Plug 'kana/vim-textobj-user'
Plug 'GCBallesteros/vim-textobj-hydrogen'

" Plug 'ubaldot/vim-conda-activate', { 'on': 'CondaActivate' }
"     map <leader>ca <cmd>CondaActivate<cr>

Plug 'vivekmyers/vim-conda', { 'on': ['CondaChangeEnv', 'CondaActivate'] }
    map <leader>ca <cmd>CondaChangeEnv<cr>
    map <leader>ci <cmd>Conda info<cr>
    command! -nargs=? Conda exe "Dispatch " . $CONDA_EXE . ' ' . <q-args>
    " let g:conda_startup_msg_suppress = 1
    " let g:conda_startup_wrn_suppress = 1

" Plug 'easymotion/vim-easymotion'
"     let g:EasyMotion_smartcase = 1
"     let g:EasyMotion_do_mapping = 0
"     map <leader>j <Plug>(easymotion-j)
"     map <leader>k <Plug>(easymotion-k)
"     map  <leader>f <Plug>(easymotion-bd-f)
"     nmap <leader>f <Plug>(easymotion-overwin-f)
"     " nmap s <Plug>(easymotion-overwin-f2)
"     map <leader>l <Plug>(easymotion-bd-jk)
"     nmap <leader>l <Plug>(easymotion-overwin-line)
"     map  <leader>w <Plug>(easymotion-bd-w)
"     nmap <leader>w <Plug>(easymotion-overwin-w)
"     map  <leader>e <Plug>(easymotion-bd-e)
"     nmap <leader>e <Plug>(easymotion-overwin-e)

Plug 'junegunn/vim-easy-align'
    xmap ga <Plug>(EasyAlign)
    nmap ga <Plug>(EasyAlign)

Plug 'davidhalter/jedi-vim'
    let g:jedi#goto_stubs_command = ""
    let g:jedi#goto_assignments_command = ""
    let g:jedi#popup_on_dot = 0

Plug 'gioele/vim-autoswap'
    let g:autoswap_detect_tmux = 1

Plug 'airblade/vim-rooter'
    let g:rooter_patterns = ['Makefile', '.git', '.hg', '.svn', '.bzr', '_darcs', '.root']
    let g:rooter_patterns += ['>Overleaf', '>Documents', '>research', '>Documents/code']

Plug 'lervag/vimtex'
    let g:tex_flavor='latex'
    let g:vimtex_quickfix_mode=0
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

    " enable shell escape
    let g:vimtex_compiler_latexmk = {
                \ 'aux_dir': '.build',
                \ 'options': [
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

Plug 'honza/vim-snippets'

" Plug 'KeitaNakamura/tex-conceal.vim'
"     set conceallevel=0
"     let g:tex_conceal=''
"     hi Conceal ctermbg=none

Plug 'psf/black', { 'branch': 'stable' }
    nnoremap <leader>bl :Black<cr>

" Plug 'haya14busa/vim-easyoperator-phrase'
" Plug 'haya14busa/vim-easyoperator-line'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
    let g:airline_theme='violet'
    let g:airline_solarized_bg='dark'
    let g:airline_powerline_fonts = 1
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#formatter = 'unique_tail'


Plug 'yegappan/mru'
    nmap <leader>o <cmd>MRU<cr>
    nmap <leader><leader>o :MRU<space>
    let g:MRU_FuzzyMatch = 0

Plug 'jlanzarotta/bufexplorer'

Plug 'dense-analysis/ale'
    let g:ale_linters = {
                \   'python': ['pylint'],
                \   'html': ['htmlhint', 'tidy'],
                \   'tex': ['latexindent'],
                \}
    let g:ale_fixers = {
                \   'python': ['black', 'autoimport', 'remove_trailing_lines', 'trim_whitespace', 'autoflake'],
                \   'tex': ['latexindent'],
                \   'html': ['html-beautify', 'tidy', 'prettier', 'remove_trailing_lines', 'trim_whitespace'],
                \   'bib': ['bibclean'],
                \}
    let g:ale_html_tidy_executable = '/usr/local/bin/tidy'
    let g:ale_python_flake8_options = '--max-line-length=120'
    let g:ale_python_black_options = '--line-length=120'
    let g:ale_python_pylint_options = '--disable=C,R,F'
    let g:ale_tex_latexindent_options = '-c=.build/'
    nmap <space>at <cmd>ALEToggle<cr>
    nmap <space>ai <cmd>ALEInfo<cr>
    nmap <C-H> :ALEFix<cr>
    nmap <silent> <C-K> <plug>(ale_previous_wrap)
    nmap <silent> <C-J> <plug>(ale_next_wrap)
    let g:ale_fixers['*'] = ['remove_trailing_lines', 'trim_whitespace']
    let g:ale_javascript_prettier_options = '--use-tabs'

Plug 'jeetsukumaran/vim-pythonsense'
" Plug 'jupyter-vim/jupyter-vim'
Plug 'sillybun/vim-repl'


Plug 'altercation/vim-colors-solarized'
Plug 'alvan/vim-closetag'

Plug 'sirver/ultisnips'
    let g:UltiSnipsExpandTrigger = '<tab>'
    let g:UltiSnipsJumpForwardTrigger = '<tab>'
    let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

Plug 'github/copilot.vim'
    imap <C-A> <Plug>(copilot-suggest)<Plug>(copilot-accept-word)

Plug 'Matt-A-Bennett/vim-surround-funk'

call plug#end()
