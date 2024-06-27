
function python#pipsetup()
    if empty($CONDA_PREFIX)
        return
    endif
    if empty(glob($CONDA_PREFIX . '/bin/pip'))
        execute 'Dispatch! ' . $CONDA_EXE . ' install pip'
    endif
endfunction

function python#pythondep(name)
    if empty($CONDA_PREFIX)
        return
    endif
    if empty(glob($CONDA_PREFIX . '/bin/' . a:name))
        execute 'Dispatch! pip install ' . a:name
    endif
endfunction

function python#pythonsetup()
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
endfunction

function python#addargument()
    let curpos = getpos('.')
    let arg = expand('<cword>')
    execute "normal vafo\e"
    sleep 100m
    if search('\%<''>def .*(\%>''<', 'c') == 0
        echoerr 'No function definition found'
        return
    endif
    sleep 100m
    call search('=\|\(:$\)', 'c')
    if getline('.') =~ '()'
        execute 'normal 0f(a' . arg
    else
        execute "normal vala\e"
        if getline('.') =~ '.*, *$'
            execute 'normal o' . arg . ",\e"
        else
            execute 'normal a, ' . arg
        endif
    endif
    call setpos('.', curpos)
endfunction

function python#addflag()
    let arg = expand('<cword>')
    split
    try
        tag args
    catch
        q
    endtry
    exe 'normal O' . 'parser.add_argument(''--' . arg . ''','
    try
        let finish = copilot#Complete()['completions'][0]['displayText']
        exe 'normal A' . finish
    catch
        echoerr 'No completion found'
    endtry
endfunction



function python#addmember()
    let curpos = getpos('.')
    let arg = expand('<cword>')
    execute "normal vaco\e"
    sleep 100m
    if search('\%>''<\%<''>def __init__', 'c') == 0
        echoerr 'No __init__ definition found'
        return
    endif
    sleep 100m
    execute "normal vif\e"
    execute 'normal oself.' . arg . ' = ' . arg . "\e"
    call python#addargument()
    call setpos('.', curpos)
endfunction

function python#addimport()
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
endfunction

function python#togglemember()
    let pos = getpos('.')
    let selfpos = search('\%.l\%<.cself\.\(\k\+\)\%>.c', 'nc')
    let noself = search('\%.l\%<.c\(\k\+\)\%>.c', 'nc')
    if selfpos != 0
        execute selfpos . 's/\%.l\%<.cself\.\(\k\+\)\%>.c/\1/'
    elseif noself != 0
        execute noself . 's/\%.l\%<.c\(\k\+\)\%>.c/self.\1/'
    else
        echoerr 'No var found'
    endif
    call setpos('.', pos)
endfunction

function python#run()
    write
    let l:oldmakeprg = &makeprg
    try
        setlocal makeprg=python\ %
        make
    finally
        let &l:makeprg = l:oldmakeprg
    endtry
    " Dispatch python %
endfunction

function python#jupyter()
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
endfunction

function python#ipynb_fold()
    let range = getline(v:lnum - 3, v:lnum + 2)
    for line in range
        if line =~ '^#.\?.\?%%'
            return 0
        endif
    endfor
    if v:lnum < 5
        return 0
    endif
    return 1
endfunction

function python#cell_below()
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
endfunction

function python#cell_above()
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
endfunction

function python#cell_split()
    call append(line('.'), ['', '# %%', ''])
    normal 3j
endfunction

function python#aspy()
    write
    let l:base = expand('%:p:r')
    exe 'edit +'.line('.').' '.l:base.'.py'
    exe 'bd '.l:base.'.ipynb'
    redraw!
endfunction

function python#asipynb()
    write
    let l:base = expand('%:p:r')
    exe 'edit +'.line('.').' '.l:base.'.ipynb'
    exe 'bd '.l:base.'.py'
    redraw!
endfunction

function python#around_cell()
    let lnum = line('.')
    if search('^#.\?.\?%%', 'bcW') == 0
        return 0
    endif
    let start = getpos('.')
    if search('^#.\?.\?%%', 'W') == 0
        return 0
    endif
    -1
    let end = getpos('.')
    return ['V', start, end]
endfunction

function python#inner_cell()
    let lnum = line('.')
    if search('^#.\?.\?%%', 'bcW') == 0
        return 0
    endif
    +1
    let start = getpos('.')
    if search('^#.\?.\?%%', 'W') == 0
        return 0
    endif
    -1
    let end = getpos('.')
    return ['V', start, end]
endfunction


function python#interactive()
    write
    try
        bd! ipython
    catch
    endtry
    vert term ++close ipython --no-confirm-exit --pdb --pylab=auto -i %
endfunction

function python#uninteract()
    try
        bd! ipython
    catch
    endtry
endfunction

function! s:execute_cell()
    if !jukit#splits#split_exists('output')
        call jukit#splits#output_and_history()
    endif
    call jukit#send#section(0)
    call jukit#cells#jump_to_next_cell()
endfunction

function python#word(mode)
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
endfunction
        

function python#notebooksetup()
    set filetype=python

    nmap <F3> :call jukit#splits#output_and_history()<cr>
    nmap <F4> :call jukit#splits#close_output_and_history(0)<cr>
    nmap <F5> <cmd>call jukit#splits#close_output_and_history(0)\|call jukit#splits#output_and_history()\|call jukit#send#all()<cr>
    nnoremap <space>np :call jukit#convert#notebook_convert("jupyter-notebook")<cr>

    nnoremap <c-cr> <cmd>call <sid>execute_cell()<cr>
    nnoremap <c-space> <cmd>call <sid>execute_cell()<cr>
    nnoremap ,<space> <cmd>call <sid>execute_cell()<cr>

    nnoremap <space>j :call jukit#cells#create_above(0)<cr>
    nnoremap <space>k :call jukit#cells#create_below(0)<cr>
    nnoremap <space>- <cmd>call jukit#cells#split()<cr>
    nmap ]h :call jukit#cells#jump_to_next_cell()<cr>zz
    nmap [h :call jukit#cells#jump_to_previous_cell()<cr>zz
    vmap ]h :call jukit#cells#jump_to_next_cell()<cr>m'gv``
    vmap [h :call jukit#cells#jump_to_previous_cell()<cr>m'gv``

    function! s:getvar(mode)
        call jukit#send#send_to_split(python#word(a:mode))
    endfun
    function! s:getshape(mode)
        let cmd = 'import jax; jax.tree_map(lambda x: x.shape if hasattr(x, "shape") else type(x), ' . python#word(a:mode) . ')'
        call jukit#send#send_to_split(cmd)
    endfun

    nnoremap ,v <cmd>call <sid>getvar('n')<cr>
    nnoremap ,s <cmd>call <sid>getshape('n')<cr>
    vnoremap ,v <esc><cmd>call <sid>getvar('v')<cr>gv
    vnoremap ,s <esc><cmd>call <sid>getshape('v')<cr>gv
    nnoremap <cr> :call jukit#send#line()<cr>
    vnoremap <cr> :<C-U>call jukit#send#selection()<cr>
    nnoremap <leader>cc :call jukit#send#until_current_section()<cr>
    nnoremap <leader>all :call jukit#send#all()<cr>

    nnoremap <space>j :call jukit#cells#create_below(0)<cr>
    nnoremap <space>k :call jukit#cells#create_above(0)<cr>
    nnoremap <space>ct :call jukit#cells#create_below(1)<cr>
    nnoremap <space>cT :call jukit#cells#create_above(1)<cr>
    nnoremap dah :call jukit#cells#delete()<cr>
    nnoremap <space>- :call jukit#cells#split()<cr>
    nnoremap <space>cM :call jukit#cells#merge_above()<cr>
    nnoremap <space>cm :call jukit#cells#merge_below()<cr>
    nnoremap <space>ck :call jukit#cells#move_up()<cr>
    nnoremap <space>cj :call jukit#cells#move_down()<cr>
    nnoremap <space>J :call jukit#cells#jump_to_next_cell()<cr>
    nnoremap <space>K :call jukit#cells#jump_to_previous_cell()<cr>
    nnoremap <space>ddo :call jukit#cells#delete_outputs(0)<cr>
    nnoremap <space>dda :call jukit#cells#delete_outputs(1)<cr>
    nnoremap <space>ht :call jukit#convert#save_nb_to_file(0,1,'html')<cr>
    nnoremap <space>rht :call jukit#convert#save_nb_to_file(1,1,'html')<cr>
    nnoremap <space>pd :call jukit#convert#save_nb_to_file(0,1,'pdf')<cr>
    nnoremap <space>rpd :call jukit#convert#save_nb_to_file(1,1,'pdf')<cr>
    nnoremap <leader><space> :call jukit#send#section(0)<cr>
    nnoremap <cr> :call jukit#send#line()<cr>
    vnoremap <cr> :<C-U>call jukit#send#selection()<cr>
    nnoremap <space>cc :call jukit#send#until_current_section()<cr>
    nnoremap <space>all :call jukit#send#all()<cr>
    nnoremap <C-G> :call jukit#splits#show_last_cell_output(1)<cr><C-G>

    nnoremap <leader>os :call jukit#splits#output()<cr>
    nnoremap <leader>ts :call jukit#splits#term()<cr>
    nnoremap <leader>hs :call jukit#splits#history()<cr>
    nnoremap <leader>ohs :call jukit#splits#output_and_history()<cr>
    nnoremap <leader>hd :call jukit#splits#close_history()<cr>
    nnoremap <leader>od :call jukit#splits#close_output_split()<cr>
    nnoremap <leader>ohd :call jukit#splits#close_output_and_history(1)<cr>
    nnoremap <leader>ah :call jukit#splits#toggle_auto_hist()<cr>
    nnoremap <leader>sl :call jukit#layouts#set_layout()<cr>

    highlight jukit_cellmarker_colors ctermbg=10 ctermfg=10
    augroup ipynb
        autocmd! * <buffer>
        if exists('b:matchtitle')
            silent! call matchdelete(b:matchtitle)
            unlet b:matchtitle
        else
            autocmd BufWinEnter <buffer> if !exists('b:matchtitle') | let b:matchtitle = matchadd('ToolbarButton', '###.*') | endif
            autocmd BufWinLeave <buffer> silent! call matchdelete(b:matchtitle) | unlet b:matchtitle
        endif
    augroup END

    if &foldmethod == 'expr'
        setlocal foldmethod=manual
    else
        setlocal foldmethod=expr
        setlocal foldexpr=python#ipynb_fold()
        normal! zx
    endif
    doautocmd BufWinEnter

    call textobj#user#plugin('python', {
                \   'cell': {
                \     'select-a': 'ah',
                \     'select-i': 'ih',
                \     'select-a-function': 'python#around_cell',
                \     'select-i-function': 'python#inner_cell',
                \     'sfile': expand('<sfile>'),
                \   },
                \ })

endfunction
