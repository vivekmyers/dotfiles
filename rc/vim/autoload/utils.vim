
function utils#reload()
    source $MYVIMRC
    redraw
    echom "Reloaded " . $MYVIMRC
    filetype detect
    call utils#refreshcomplete()
    doautoall FileType
    doautoall BufRead
    doautoall BufEnter
endfunction

function utils#remote(host, user = $USER)
    echom "Connecting to " . a:user . "@" . a:host
    execute "silent! Explore scp://" . a:user . "@" . a:host . "/"
endfunction


function utils#savesession()
    let startsess = g:startdir . '/' . $VIMSESSION
    let currsess = getcwd() . '/' . $VIMSESSION
    execute 'mksession! ' . currsess
    execute 'mksession! ' . startsess
    if startsess != currsess
        echo "Session saved to " . currsess . " and " . startsess
    else
        echo "Session saved to " . currsess
    endif
endfunction

function utils#refreshcomplete()
    " imap <silent><script><expr> <tab> copilot#Accept("\<C-R>=UltiSnips#ExpandSnippetOrJump()\<cr>")
endfunction


function utils#loadsession()
    let l:sess = getcwd() . "/" . $VIMSESSION
    silent! source $VIMSESSION
    echom "Session loaded from " . l:sess
    AirlineRefresh
    call utils#refreshcomplete()
endfunction


function utils#snipconf()
    let l:file = $CONFIGDIR . '/rc/vim/UltiSnips/' . &filetype . '.snippets'
    execute 'e ' . l:file
endfunction


function utils#fileconf()
    let l:file = $CONFIGDIR . '/rc/vim/ftplugin/' . &filetype . '.vim'
    execute 'e ' . l:file
endfunction

function utils#autoconf()
    let l:file = $CONFIGDIR . '/rc/vim/autoload/'
    execute 'e ' . l:file
endfunction

function utils#localconf()
    edit exrc.vim
    source exrc.vim
endfunction


function utils#forcewrite()
    augroup forcewrite
        au FileChangedShell * call <sid>file_changed()
    augroup END
    write!
    augroup forcewrite
        autocmd!
    augroup END
endfunction


function utils#file_changed()
  let v:fcs_choice = 'just do nothing'
  let filename = expand("<afile>")
  " how to detect file created event?
  if v:fcs_reason ==# 'conflict'
    echohl WarningMsg
    echo 'Warning: File "'.filename.'" has changed and the buffer was changed in Vim as well'
    echohl None
  endif
endfunction


function utils#closenext()
    try
        wnext
    catch
        try
            wq
        catch
            try
                wall
                quit
            catch
                qall
            endtry
        endtry
    endtry
endfunction

function utils#searchfiles(...)
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
endfunction

function utils#findfiles(...)
    cclose
    let args = copy(a:000)
    let flags = join(map(args, {i, v -> '-iname "*' . v . '*"'}), ' -or ')
    exe 'Cfind . \( ' . flags . ' \) -type f'
    copen
endfunction


function utils#newdir()
    let exrc = glob('{exrc.vim,_exrc,_vimrc,.exrc,.vimrc}', 1, 1)
    for rcfile in exrc
        if filereadable(rcfile)
            exe 'source ' . rcfile
        endif
    endfor
endfunction


function utils#gotosymlink()
    let l:file = expand("%")
    if !isdirectory(l:file)
        let l:link = fnamemodify(l:file, ":p")
        if filereadable(l:link)
            exe 'e ' . l:link
        endif
    endif
endfunction

function utils#note(...)
    if a:0 == 0
        Explore ~/Documents/notes
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
        call feedkeys("idoc\<C-R>=UltiSnips#ExpandSnippetOrJump()\<CR>")
    endif
endfunction


function utils#dircmd(cmd)
    if &ft ==# "netrw"
        normal cd
        let l:pwd = getcwd()
        tabnew
        exe 'cd ' . l:pwd
    endif
    exe a:cmd
    write
    AirlineRefresh
endfunction
