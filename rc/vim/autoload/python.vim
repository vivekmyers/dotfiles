
fun python#pipsetup()
    if empty($CONDA_PREFIX)
        return
    endif
    if empty(glob($CONDA_PREFIX . '/bin/pip'))
        execute 'Dispatch! ' . $CONDA_EXE . ' install pip'
    endif
endfun

fun python#pythondep(name)
    if empty($CONDA_PREFIX)
        return
    endif
    if empty(glob($CONDA_PREFIX . '/bin/' . a:name))
        execute 'Dispatch! pip install ' . a:name
    endif
endfun

fun python#pythonpak(name)
    call system("python -c 'import " . a:name . "' 2>/dev/null")
    if v:shell_error != 0
        execute 'Dispatch! pip install ' . a:name
    endif
endfun

fun python#pythonsetup()
    call python#pipsetup()

    call python#pythondep('pylint')
    call python#pythondep('autopep8')
    call python#pythondep('black')
    call python#pythondep('autoflake')
    call python#pythondep('autoimport')
    call python#pythondep('ipython')
    call python#pythondep('jupyter')
    call python#pythondep('jupytext')
    call python#pythondep('jupyter-console')

    call python#pythonpak('matplotlib')
    call python#pythonpak('imgcat')
endfun

fun python#addargument()
    let curpos = getpos('.')
    let arg = expand('<cword>')
    execute "normal vafo\e"
    if search('\%<''>def .*(\%>''<', 'c') == 0
        echoerr 'No function definition found'
        return
    endif
    call search('=\|\(:$\)', 'c')
    if getline('.') =~ '()'
        execute 'normal 0f(a' . arg
    else
        call search('.[),]', 'bW')
        execute "normal vaa\e"
        if getline('.') =~ '.*, *$'
            execute 'normal o' . arg . ",\e"
        else
            execute 'normal a, ' . arg
        endif
    endif
    call setpos('.', curpos)
endfun

fun python#addflag()
    let arg = expand('<cword>')
    split
    try
        tag args
    catch
        q
    endtry
    exe 'normal O' . 'parser.add_argument(''--' . arg . ''','
    " try
        normal $
        let finish = copilot#Complete()['items'][0]['insertText']
        exe 'normal cc' . finish
    " catch
    "     echoerr 'No completion found'
    " endtry
endfun



fun python#addmember()
    let curpos = getpos('.')
    let arg = expand('<cword>')
    execute "normal vaco\e"
    if search('\%>''<\%<''>def __init__', 'c') == 0
        echoerr 'No __init__ definition found'
        return
    endif
    execute "normal vif\e"
    execute 'normal oself.' . arg . ' = ' . arg . "\e"
    call python#addargument()
    call setpos('.', curpos)
endfun

fun python#addimport()
    let arg = expand('<cword>')

    let cmd = 'import ' . arg

    if arg == 'np'
        let cmd = 'import numpy as np'
    elseif arg == 'pd'
        let cmd = 'import pandas as pd'
    elseif arg == 'plt'
        let cmd = 'import matplotlib.pyplot as plt'
    elseif arg == 'tf'
        let cmd = 'import tensorflow as tf'
    elseif arg == 'jnp'
        let cmd = 'import jax.numpy as jnp'
    elseif arg == 'nn'
        let cmd = 'import torch.nn as nn'
    elseif arg == 'F'
        let cmd = 'import torch.nn.functional as F'
    elseif arg == 'sns'
        let cmd = 'import seaborn as sns'
    elseif arg == 'mpl'
        let cmd = 'import matplotlib as mpl'
    elseif arg == 'plt'
        let cmd = 'import matplotlib.pyplot as plt'
    elseif arg == 'partial'
        let cmd = 'from functools import partial'
    elseif arg == 'reduce'
        let cmd = 'from functools import reduce'
    elseif arg == 'compose'
        let cmd = 'from functools import compose'
    elseif arg == 'islice'
        let cmd = 'from itertools import islice'
    elseif arg == 'chain'
        let cmd = 'from itertools import chain'
    elseif arg == 'count'
        let cmd = 'from itertools import count'
    elseif arg == 'cycle'
        let cmd = 'from itertools import cycle'
    elseif arg == 'repeat'
        let cmd = 'from itertools import repeat'
    elseif arg == 'defaultdict'
        let cmd = 'from collections import defaultdict'
    elseif arg == 'hk'
        let cmd = 'import haiku as hk'
    elseif arg == 'optax'
        let cmd = 'import optax'
    elseif arg == 'flax'
        let cmd = 'import flax'
    elseif index(['Pytree', 'static_field'], arg) != -1
        let cmd = 'from simple_pytree import Pytree, static_field'
    elseif index(['TypeVar', 'Generic', 'List', 'Dict', 'Tuple', 'Optional', 'Union', 'Any', 'Callable'], arg) != -1
        let cmd = 'from typing import ' . arg
    endif

    if search(cmd . '[[:space:]]*$', 'cbn') != 0
        echoerr 'Already imported'
        return
    endif

    let iline = search('^import\|^from', 'cbn')
    call append(iline, cmd)

    if line('.') > iline + 35
        split
        call cursor(iline + 1, 1)
    else
        normal! zb
    endif
endfun

fun python#togglemember()
    let pos = getpos('.')
    let selfpos = search('\%.l\%<.c.\?\zsself\.\(\k\+\)\%>.c', 'nc')
    let noself = search('\%.l\%<.c.\?\zs\(\k\+\)\%>.c', 'nc')
    if selfpos != 0
        execute selfpos . 's/\%.l\%<.c.\?\zsself\.\(\k\+\)\%>.c/\1/'
    elseif noself != 0
        execute noself . 's/\%.l\%<.c.\?\zs\(\k\+\)\%>.c/self.\1/'
    else
        echoerr 'No var found'
    endif
    call setpos('.', pos)
endfun

fun python#deleteattribution()
    let pos = getpos('.')
    let opos = search('\%.l\%<.c.\?\zs\k\+\(\.\k\+\)*\.\(\k\+\)\%>.c', 'nc')
    if opos != 0
        execute opos . 's/\%.l\%<.c.\?\zs\k\+\(\.\k\+\)*\.\(\k\+\)\%>.c/\2/'
    else
        echoerr 'No var found'
    endif
    call setpos('.', pos)
endfun

fun python#run()
    write
    let l:oldmakeprg = &makeprg
    try
        setlocal makeprg=python\ %
        make
    finally
        let &l:makeprg = l:oldmakeprg
    endtry
    " Dispatch python %
endfun

fun python#jupyter()
    wall
    let spc = trim(system('yabai -m query --spaces --window | jq ".[].index"'))
    let cmd = 'yabai -m query --windows | jq ''.[] | select(.app == "JupyterLab" and .space != '.spc.' and (.["is-visible"] | not)) | .id'' | xargs -I{} -n1 yabai -m window {} --space '.spc.' --focus'
    call system("bash -c " . shellescape(cmd))
    let notebook = expand('%:p:r') . '.ipynb'

    if !exists(notebook)
        call system('jupytext --to ipynb ' . expand('%:p'))
    endif

    let mvwind = system('yabai -m query --windows | jq ''.[] | select(.app == "MacVim") | .id''')

    call system('osascript -e "tell application \"JupyterLab\" to quit"')
    call system('open -a JupyterLab ' . shellescape(notebook))


    for i in range(1, 50)
        let jwind = system('yabai -m query --windows | jq ''.[] | select(.app == "JupyterLab") | .id''')
        let jwind = trim(jwind)
        let jwind = str2nr(jwind)
        sleep 100m
        if jwind != 0
            break
        endif
    endfor

    let script =<< trim END
        tell application "Image Events"
            launch
            set allDisplays to properties of displays
            set n to length of allDisplays

            tell application "Finder"
                set screen_resolution to bounds of window of desktop
                set i to item 3 of screen_resolution
                if i = 1512 then
                    set n to n - 1
                end if
            end tell
        end tell
        n
    END
    let n = trim(system('osascript -e ' . shellescape(join(script, "\r"))))
    let n = str2nr(n)

    if n == 0
        call system('yabai -m window '.shellescape(mvwind).' --grid 1:1512:0:0:890:1')
        call system('yabai -m window '.shellescape(jwind).' --grid 1:1512:890:0:622:1')
    elseif n == 1
        call system('yabai -m window '.shellescape(mvwind).' --grid 1:1920:0:0:1216:1')
        call system('yabai -m window '.shellescape(jwind).' --grid 1:1920:1216:0:704:1')
    elseif n > 1
        " let script =<< trim END
        "     tell application "System Events"
        "         set mv to front window of application "MacVim"
        "         set bounds of mv to {0, 38, 1512, 980}
        "     end tell
        " END
        " call system('osascript -e ' . shellescape(join(script, "\r")))
        call system('yabai -m window '.shellescape(mvwind).' --grid 1:1:0:0:1:1')
        call system('yabai -m window '.shellescape(jwind).' --display 2 --grid 1:1:0:0:1:1')
    endif

    call system('osascript -e "tell application \"MacVim\" to activate"')
endfun

fun python#ipynb_fold()
    let curline = getline(v:lnum)
    if curline =~ '^#.\?.\?%%'
        return 0
    endif
    if v:lnum < 5
        let range = getline(1, line('$'))
        for line in range
            if line =~ 'r\?"""°°°\|^###'
                return 0
            endif
        endfor
        return 1
    endif
    let range = getline(v:lnum - 4, v:lnum + 3)
    for line in range
        if line =~ 'r\?"""°°°\|^###'
            return 0
        endif
    endfor
    let range = getline(v:lnum - 3, v:lnum + 2)
    for line in range
        if line =~ '^#.\?.\?%%'
            return 1
        endif
    endfor
    return 2
endfun

fun python#cell_below()
    let curpos = getpos('.')
    let lnum = search('^# \?%%', 'nW')
    if lnum == 0
        let lnum = line('$')
        if getline(lnum) =~ '^# \?%%'
            call append(lnum, ['', '', '', '# %%'])
            call cursor(lnum + 2, 1)
        else
            call append(lnum, ['', '# %%', '', ''])
            call cursor(lnum + 4, 1)
        endif
    else
        call append(lnum, ['', '', '', '# %%'])
        call cursor(lnum + 2, 1)
    endif
    startinsert
endfun

fun python#cell_above()
    let curpos = getpos('.')
    let lnum = search('^# \?%%', 'bncW')
    if lnum == 0
        let lnum = 1
        if getline(lnum) =~ '^# \?%%'
            call append(lnum - 1, ['# %%', '', '', ''])
            call cursor(lnum + 2, 1)
        else
            call append(lnum - 1, ['', '', '# %%', ''])
            call cursor(lnum, 1)
        endif
    else
        call append(lnum - 1, ['# %%', '', '', ''])
        call cursor(lnum + 2, 1)
    endif
    startinsert
endfun

fun python#cell_split()
    call append(line('.'), ['', '# %%', ''])
    normal 3j
endfun

fun python#aspy()
    write
    let l:base = expand('%:p:r')
    exe 'edit +'.line('.').' '.l:base.'.py'
    exe 'bd '.l:base.'.ipynb'
    redraw!
endfun

fun python#asipynb()
    write
    let l:base = expand('%:p:r')
    exe 'edit +'.line('.').' '.l:base.'.ipynb'
    exe 'bd '.l:base.'.py'
    redraw!
endfun

fun python#around_cell()
    let lnum = line('.')
    if search('^#.\?.\?%%', 'bcW') == 0
        0
    endif
    let start = getpos('.')
    if search('^#.\?.\?%%', 'W') == 0
        $
    else
        -1
    endif
    let end = getpos('.')
    if end[1] == line('$') && start[1] == 0
        return 0
    endif
    return ['V', start, end]
endfun

fun python#inner_cell()
    let lnum = line('.')
    if search('^#.\?.\?%%', 'bcW') == 0
        0
    else
        +1
    endif
    let start = getpos('.')
    if search('^#.\?.\?%%', 'W') == 0
        $
    else
        -1
    endif
    let end = getpos('.')
    if end[1] == line('$') && start[1] == 0
        return 0
    endif
    return ['V', start, end]
endfun


fun python#interactive()
    write
    try
        bd! ipython
    catch
    endtry
    vert term ++close ipython --no-confirm-exit --pdb --pylab=auto -i %
endfun

fun python#uninteract()
    try
        bd! ipython
    catch
    endtry
endfun

fun! s:execute_cell()
    if !jukit#splits#split_exists('output')
        call s:jukitstart()
    endif
    call jukit#send#section(0)
    call jukit#cells#jump_to_next_cell()
endfun

fun s:jukitcmd(cmd)
    exe "call jukit#" . a:cmd 
endfun

fun python#word(mode)
    if a:mode == 'v'
        let word = jukit#util#get_visual_selection()
    else
        let line = getline('.')
        let word = matchstr(line, '\(\k\.\|\k\)*\%'.col('.').'c\k\+')
    endif
    if word == ''
        let word = expand('<cword>')
    endif
    return word
endfun
        

fun s:jukitstart()
    call jukit#splits#output_and_history()
    if g:jukit_terminal == 'tmux'
        " silent! Tmux select-pane -L
        " silent! Tmux select-layout main-vertical
        " silent! Tmux move-pane -L
        let width = str2nr(trim(execute('silent! Tmux display -p \#{window_width}')))
        exe 'silent! Tmux resize-pane -x ' . float2nr(width - 40 - 2*sqrt(width))
        " call system('tmux list-panes -aF "#S.#D" | xargs -n1 -I{} tmux send-keys -t {} enter')
    endif
endfun

fun! python#notebooksetup()
    set filetype=python

    nmap <buffer> <F3> :call <sid>jukitstart()<cr>
    nmap <buffer> <C-F3> :call <sid>jukitstart()<cr><space>cc
    nmap <buffer> <F4> :call jukit#splits#close_output_and_history(0)<cr>
    nmap <buffer> <leader><F3> <cmd>call jukit#splits#close_output_and_history(0)\|call <sid>jukitstart()\|call <sid>jukitcmd('send#all()')<cr>
    nnoremap <buffer> <space>np :call jukit#convert#notebook_convert("jupyter-notebook")<cr>

    nnoremap <buffer> <c-cr> <cmd>call <sid>execute_cell()<cr>
    nnoremap <buffer> <cr><cr> <cmd>call <sid>execute_cell()<cr>
    nnoremap <buffer> <c-space> <cmd>call <sid>execute_cell()<cr>
    nnoremap <buffer> ,<space> <cmd>call <sid>execute_cell()<cr>

    nnoremap <buffer> <space>j :call jukit#cells#create_above(0)<cr>
    nnoremap <buffer> <space>k :call jukit#cells#create_below(0)<cr>
    nnoremap <buffer> <space>- <cmd>call jukit#cells#split()<cr>
    nmap <buffer> ]h :call jukit#cells#jump_to_next_cell()<cr>
    nmap <buffer> [h :call jukit#cells#jump_to_previous_cell()<cr>
    vmap <buffer> ]h :call jukit#cells#jump_to_next_cell()<cr>m'gv``
    vmap <buffer> [h :call jukit#cells#jump_to_previous_cell()<cr>m'gv``

    map <buffer> <C-J> ]h
    map <buffer> <C-K> [h

    fun! s:getvar(mode)
        call jukit#send#send_to_split(python#word(a:mode))
    endfun
    fun! s:getshape(mode)
        let cmd = 'import jax; jax.tree_util.tree_map(lambda x: x.shape if hasattr(x, "shape") else type(x), ' . python#word(a:mode) . ')'
        call jukit#send#send_to_split(cmd)
    endfun

    nnoremap <buffer> ,v <cmd>call <sid>getvar('n')<cr>
    nnoremap <buffer> ,s <cmd>call <sid>getshape('n')<cr>
    vnoremap <buffer> ,v <esc><cmd>call <sid>getvar('v')<cr>gv
    vnoremap <buffer> ,s <esc><cmd>call <sid>getshape('v')<cr>gv
    nnoremap <buffer> <cr> :call <sid>jukitcmd('send#line()')<cr>
    vnoremap <buffer> <cr> :<C-U>call <sid>jukitcmd('send#selection()')<cr>

    nnoremap <buffer> <leader>cc :call <sid>jukitcmd('send#until_current_section()')<cr>
    nnoremap <buffer> <leader>all :call <sid>jukitcmd('send#all()')<cr>

    nnoremap <buffer> <space>j :call jukit#cells#create_below(0)<cr>
    nnoremap <buffer> <space>k :call jukit#cells#create_above(0)<cr>
    nnoremap <buffer> <space>ct :call jukit#cells#create_below(1)<cr>
    nnoremap <buffer> <space>cT :call jukit#cells#create_above(1)<cr>
    " nnoremap <buffer> dah yahj:call jukit#cells#delete()<cr>
    nnoremap <buffer> <space>- :call jukit#cells#split()<cr>
    nnoremap <buffer> <space>cM :call jukit#cells#merge_above()<cr>
    nnoremap <buffer> <space>cm :call jukit#cells#merge_below()<cr>
    nnoremap <buffer> <space>ck :call jukit#cells#move_up()<cr>
    nnoremap <buffer> <space>cj :call jukit#cells#move_down()<cr>
    nnoremap <buffer> <space>J :call jukit#cells#jump_to_next_cell()<cr>
    nnoremap <buffer> <space>K :call jukit#cells#jump_to_previous_cell()<cr>
    nnoremap <buffer> <space>ddo :call jukit#cells#delete_outputs(0)<cr>
    nnoremap <buffer> <space>dda :call jukit#cells#delete_outputs(1)<cr>
    nnoremap <buffer> <space>ht :call jukit#convert#save_nb_to_file(0,1,'html')<cr>
    nnoremap <buffer> <space>rht :call jukit#convert#save_nb_to_file(1,1,'html')<cr>
    nnoremap <buffer> <space>pd :call jukit#convert#save_nb_to_file(0,1,'pdf')<cr>
    nnoremap <buffer> <space>rpd :call jukit#convert#save_nb_to_file(1,1,'pdf')<cr>
    nnoremap <buffer> <leader><space> :call <sid>jukitcmd('send#section(0)')<cr>
    " nnoremap <buffer> <cr> :call <sid>jukitcmd('send#line()')<cr>
    vnoremap <buffer> <cr> :<C-U>call <sid>jukitcmd('send#selection()')<cr>
    nnoremap <buffer> <space>cc :call <sid>jukitcmd('send#until_current_section()')<cr>
    nnoremap <buffer> <space>all :call <sid>jukitcmd('send#all()')<cr>
    nnoremap <buffer> <C-G> :call jukit#splits#show_last_cell_output(1)<cr><C-G>

    nnoremap <buffer> <leader>os :call jukit#splits#output()<cr>
    nnoremap <buffer> <leader>ts :call jukit#splits#term()<cr>
    nnoremap <buffer> <leader>hs :call jukit#splits#history()<cr>
    nnoremap <buffer> <leader>ohs :call <sid>jukitstart()<cr>
    nnoremap <buffer> <leader>hd :call jukit#splits#close_history()<cr>
    nnoremap <buffer> <leader>od :call jukit#splits#close_output_split()<cr>
    nnoremap <buffer> <leader>ohd :call jukit#splits#close_output_and_history(1)<cr>
    nnoremap <buffer> <leader>ah :call jukit#splits#toggle_auto_hist()<cr>
    nnoremap <buffer> <leader>sl :call jukit#layouts#set_layout()<cr>

    function! OpJukitSend(mot_wise)
        if !jukit#splits#split_exists('output')
            call s:jukitstart()
        endif
        let pos = getcurpos()
        
        normal `[V`]
        call jukit#send#selection()
        normal ']j
    endfunction

    call operator#user#define('jupyter-send', 'OpJukitSend')
    map <buffer> <cr> <Plug>(operator-jupyter-send)


    highlight jukit_cellmarker_colors ctermbg=10 ctermfg=10
    hi Header cterm=bold ctermfg=0 ctermbg=7 gui=bold guifg=Black guibg=LightGrey

    setlocal foldmethod=expr
    setlocal foldexpr=python#ipynb_fold()
    normal! zx
    normal! zR
    doautocmd BufWinEnter

    augroup jukit
        autocmd!
        autocmd VimLeave * call jukit#splits#close_output_and_history(0)
    augroup END

    call textobj#user#plugin('python', {
                \   'cell': {
                \     'select-a': 'ah',
                \     'select-i': 'ih',
                \     'select-a-function': 'python#around_cell',
                \     'select-i-function': 'python#inner_cell',
                \     'sfile': expand('<sfile>'),
                \   },
                \ })

    if search('argparse', 'ncW') > 0
        if search('sys\.argv *=' , 'ncW') == 0
            exe "normal gg\<space>-kOmakeargs\<C-A>\e"
            write
            edit
        endif
    endif

endfun
