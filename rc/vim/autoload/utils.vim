" Author: Vivek Myers <vivek.myers@gmail.com>
" Date: 2024-09-02

fun utils#reload()
    source $MYVIMRC
    redraw
    echom "Reloaded " . $MYVIMRC
    filetype detect
    call utils#refresh()
    doautoall FileType
    doautoall BufRead
    doautoall BufEnter
endfun

fun utils#remote(host, user = $USER)
    echom "Connecting to " . a:user . "@" . a:host
    execute "silent! Explore scp://" . a:user . "@" . a:host . "/"
endfun

fun utils#savesession()
    let startsess = g:startdir . '/' . $VIMSESSION
    let currsess = getcwd() . '/' . $VIMSESSION
    execute 'mksession! ' . currsess
    execute 'mksession! ' . startsess
    if startsess != currsess
        echo "Session saved to " . currsess . " and " . startsess
    else
        echo "Session saved to " . currsess
    endif
endfun

fun utils#refresh()
    AirlineToggle
    AirlineToggle
    highlight link ALEErrorSign error
    highlight link ALEWarningSign todo
    redraw
    vnew
    redraw
    bdelete
    redraw!
    AirlineRefresh
    " imap <silent><script><expr> <tab> copilot#Accept("\<C-R>=UltiSnips#ExpandSnippetOrJump()\<cr>")
endfun

fun utils#loadsession()
    let l:sess = getcwd() . "/" . $VIMSESSION
    silent! source $VIMSESSION
    echom "Session loaded from " . l:sess
    AirlineRefresh
    call utils#refresh()
endfun

fun utils#snipconf()
    let l:file = $CONFIGDIR . '/rc/vim/UltiSnips/' . &filetype . '.snippets'
    execute 'e ' . l:file
endfun

fun utils#fileconf()
    let l:file = $CONFIGDIR . '/rc/vim/ftplugin/' . &filetype . '.vim'
    let l:alt = $HOME . '/.vim/ftplugin/' . &filetype . '.vim'
    execute 'e ' . l:file
    exe "au BufWrite <buffer> ++once call system('ln -sf ".l:file." ".l:alt."')"
endfun

fun utils#autoconf()
    let l:file = $CONFIGDIR . '/rc/vim/autoload/'
    execute 'e ' . l:file
endfun

fun utils#localconf()
    edit exrc.vim
    autocmd! BufWinLeave <buffer> source %
endfun

fun utils#forcewrite()
    augroup forcewrite
        au FileChangedShell * call <sid>file_changed()
    augroup END
    write!
    augroup forcewrite
        autocmd!
    augroup END
endfun

fun utils#file_changed()
  let v:fcs_choice = 'just do nothing'
  let filename = expand("<afile>")
  " how to detect file created event?
  if v:fcs_reason ==# 'conflict'
    echohl WarningMsg
    echo 'Warning: File "'.filename.'" has changed and the buffer was changed in Vim as well'
    echohl None
  endif
endfun

fun utils#closenext()
    " try
    "     wnext
    " catch
    silent! write
    try
        close
    catch
        wall
        quit
        " try
        "     quit
        " catch
        "     silent! wall
        "     qall
        " endtry
    endtry
    " endtry
endfun

fun utils#searchfiles(...)
    cclose
    let pat = '\(' . join(a:000, '\)\|\(') . '\)'
    if a:0 == 0
        let pat = @/
    endif
    let ext = expand("%:e")
    try
        call feedkeys('/\c' . pat . "\<cr>")
    catch
    endtry
    try
        exe $'vimgrep /\c{pat}/j **/*.' . ext
    catch
    endtry
    copen
endfun

fun utils#findfiles(...)
    cclose
    let args = copy(a:000)
    let flags = join(map(args, {i, v -> '-iname "*' . v . '*"'}), ' -or ')
    exe 'Cfind . \( ' . flags . ' \) -type f'
    copen
endfun

fun utils#newdir()
    if getcwd() == $HOME
        return
    endif
    let exrc = glob('{exrc.vim,_exrc,_vimrc,.exrc,.vimrc}', 1, 1)
    for rcfile in exrc
        if filereadable(rcfile)
            exe 'source ' . rcfile
        endif
    endfor
endfun

fun utils#gotosymlink()
    let l:file = expand("%")
    if !isdirectory(l:file)
        let l:link = fnamemodify(l:file, ":p")
        if filereadable(l:link)
            exe 'e ' . l:link
        endif
    endif
endfun

fun utils#note(...)
    if a:0 == 0
        Explore ~/Documents/notes
        call feedkeys("s")
        return
    else
        let note = a:1
    endif
    let l:dir = '~/Documents/notes/' . note
    let l:file = '~/Documents/notes/' . note . '/main.tex'
    if filereadable(expand(l:file))
        exe 'e ' . l:file
    else
        call system('mkdir -p ' . l:dir)
        call system('cd ' . l:dir . ' && touch main.tex && git init && touch references.bib && git add * && git commit -m "Initial commit"')
        exe 'cd ' . l:dir
        Template! note
        exe 'e ' . l:file
    endif
endfun

fun utils#fig(...)
    if a:0 == 0
        Explore ~/Documents/notes
        call feedkeys("s")
        return
    else
        let note = a:1
    endif
    let l:dir = '~/Documents/notes/' . note
    let l:file = '~/Documents/notes/' . note . '/' . note . '.tex'
    if filereadable(expand(l:file))
        exe 'e ' . l:file
    else
        call system('mkdir -p ' . l:dir)
        call system('cd ' . l:dir . ' && touch ' . note . '.tex && git init && touch references.bib && git add * && git commit -m "Initial commit"')
        exe 'e ' . l:file
        exe 'cd ' . l:dir
        call feedkeys("istand\<C-R>=UltiSnips#ExpandSnippetOrJump()\<CR>")
    endif
endfun

fun utils#dircmd(cmd)
    if &ft ==# "netrw"
        normal cd
        let l:pwd = getcwd()
        tabnew
        exe 'cd ' . l:pwd
    endif
    exe a:cmd
    write
    AirlineRefresh
endfun

fun utils#leftview()
    silent! Tmux move-pane -L
    silent! Tmux select-layout main-vertical
    silent! Tmux move-pane -L
    let width = str2nr(trim(execute('silent! Tmux display -p \#{window_width}')))
    exe 'silent! Tmux resize-pane -x ' . float2nr(width - 40 - 2*sqrt(width))
    silent! Tmux select-pane -L
    let winno = winnr()
    silent! windo wincmd J
    exe winno . 'wincmd w'
    silent! wincmd H
    silent! wincmd =
    sleep 100m
    silent! Tmux select-pane -L
    silent! exe 'vert resize ' . float2nr(&columns - 40 - 3*sqrt(&columns))
    normal! zz
endfun

fun utils#diff()
    cclose
    try
        1,2windo diffthis
    catch
        diffs #
    endtry
endfun

fun utils#date()
    let l:date = strftime("%Y-%m-%d")
    return l:date
endfun

fun utils#template(force, name)
    exe '!zsh -lc '.shellescape('template '.a:name.' '.(a:force ? '-f' : ''))
endfun

fun utils#templates(...)
    let l:dir = '~/templates'
    let l:files = split(glob(l:dir . '/*'), '\n')->map({i, v -> fnamemodify(v, ':t')})
    return l:files->join("\n")
endfun

fun utils#mine(...)
    call append(0, "")
    normal gg
    exe "normal Oauthor\<C-A>"
    exe "normal oDate: date\<C-A>"
    normal gcip
    normal j
endfun

fun utils#conf(...)
    if a:0 == 0
        exe '!zsh -c commit_config'
    else
        let name = system('conf -p ' . a:1)
        if name != ''
            exe 'e ' . name
            autocmd BufWinLeave <buffer> ++once exe '!zsh -c commit_config'
        endif
    endif
endfun

fun utils#closebuf()
    if &ft == 'netrw'
        " call feedkeys("------------/Users\<cr>\<cr>/".$USER."\<cr>\<cr>/config\<cr>\<cr>/makefile\<cr>\<cr>:bdelete\<cr>")
        exe 'Ntree '.$HOME.'/.vim/'
        Explore *//plug
        Nexplore
        exe "normal \<cr>"
        bdelete
    elseif len(getbufinfo({'buflisted':1})) == 1
        if &buftype ==# 'terminal'
            silent! bd!
        else
            update
            silent! Bdelete
        endif
    else
        if &buftype ==# 'terminal'
            " buffer! #
            " silent! bdelete! #
            silent! bd!
        else
            update
            silent! Bdelete
        endif
    endif
endfun


fun utils#untitlecase(x)
    let x = substitute(a:x, '\<\w', '\l\0', 'g')
    let x = substitute(x, '\(^\|\.\)\s*\w', '\u\0', 'g')
    return x
endfun

fun utils#templatesyntax()
    unlet! b:current_syntax
    syn include @perl syntax/perl.vim
    hi TemplateDelimiter cterm=bold gui=underline,reverse guifg=#586e75 guibg=#eee8d5 
    syn region Template start="<%" end="%>" contains=@perl,TemplateDelimiter matchgroup=TemplateDelimiter keepend
    syn match TemplateDelimiter "<%" contained
    syn match TemplateDelimiter "%>" contained
endfun

fun utils#install(giturl)
    let id = execute('perl "'.a:giturl.'"=~m|([\w.-]+/[\w.-]+)(\.git)?(\?.*)?$|;chomp $1;print $1')
    if id == ''
        echoerr "Invalid git url"
        return
    endif
    edit ~/config/rc/vim/autoload/load.vim
    normal G?^Plug
    exe 'normal oPlug ''' . trim(id) . ''''
    write
    edit ~/config/rc/vim/autoload/plugins.vim
    normal G
    normal o
    exe 'normal o"Plug ''' . trim(id) . ''''
    write
    exe 'Plug ''' . trim(id) . ''''
    PlugInstall
endfun

fun utils#generate_commit_message()
  let l:diff = system('git --no-pager diff --staged')

  let l:prompt = "generate a commit message from the diff below, _without_ any surrounding quotes, only one line:\n" . l:diff[:min([len(l:diff), 1000])] . "\n" . "reminder: only one line, no quotes, no trailing whitespace"
  exe "AI " . l:prompt
endfun
