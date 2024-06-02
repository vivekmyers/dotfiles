
function tex#comments(filter = '')
    let l:prg =<< trim END
        git grep -nI 
        '^\([^%]*%%\)\?[[:space:]]*[A-Z][A-Z]\(\.[0-9]*\)*:\|^[^%]*\\todo.*$\|\<TODO\>\|\\adnote'
        | grep -v '\[resolved.*\]'
    END
    if a:filter != ''
        let l:prg = l:prg + [' | grep ' . shellescape(a:filter)]
    endif
    exe 'Grepper -noprompt -tool git -grepprg ' . join(l:prg, " ")
endfunction

function tex#togmark()
    let l:line = line('.')
    call cursor(0, 1)
    if search('resolved', 'c', l:line) == l:line
        call tex#unresolve()
    endif
    let l:match1 = search('^[^%]*%%%[A-Z][A-Z]\(\.[0-9]*\)*:', 'c', l:line)
    let l:match2 = search('^[^%]*%%[A-Z][A-Z]\(\.[0-9]*\)*:', 'c', l:line)
    if l:match1 == l:line
        execute "normal! f%x"
    elseif l:match2 == l:line
        execute "normal! f%i%"
    endif
endfunction

function tex#togresolve()
    call cursor(0, 1)
    if search('resolved', 'c', line('.')) == line('.')
        call tex#unresolve()
    else
        call tex#resolve()
    endif
endfunction

function tex#nextcomment()
    call cursor(0, 1)
    call search('^[^%]*%%[A-Z][A-Z]\(\.[0-9]*\)*:', '')
endfunction

function tex#prevcomment()
    call cursor(0, 1)
    call search('^[^%]*%%[A-Z][A-Z]\(\.[0-9]*\)*:', 'b')
endfunction

function tex#resolve()
    let l:line = line('.')
    call cursor(0, 1)
    let l:match = search('^[^%]*%%[A-Z][A-Z]\(\.[0-9]*\)*:', 'c', l:line)
    if l:match == l:line
        execute "normal! f:i[resolved: ".tex#stamp()."]"
    endif
endfunction

function tex#unresolve()
    let l:line = line('.')
    call cursor(0, 1)
    let l:match = search('resolved', 'c', l:line)
    if l:match == l:line
        execute('normal! da[')
    endif
endfunction

function tex#getpack()
    let l:pack = systemlist('sed -n "s/.*\\usepackage{\(.*\)}.*/\1/p" ' . join(glob('*.tex', 0, 1), ' '))
    return l:pack
endfunction

function tex#showdef()
    let l:cmd = expand('<cword>')
    let l:result = system('latexdef -sF -p ' . join(tex#getpack(), ' -p ') . ' ' . l:cmd)
    echo l:result
endfunction

function tex#gotodef()
    let l:cmd = expand('<cword>')
    let l:results = systemlist('latexdef -sF -p ' . join(tex#getpack(), ' -p ') . ' ' . l:cmd)
    let l:result = l:results[0]
    let l:match = matchlist(l:result, '% \(.*\), line \([0-9]*\):')

    if len(l:match) == 0
        echo join(l:results)
        return
    endif

    let l:file = l:match[1]
    let l:line = l:match[2]

    let pos = [bufnr()] + getcurpos()[1:]
    let item = {'bufnr': pos[0], 'from': pos, 'tagname': l:cmd}

    execute 'edit ' . l:file
    call cursor(l:line, 0)
    let [lnum, col] = searchpos(l:cmd, 'c', l:line)
    call cursor(l:line, col)

    let winid = win_getid()
    let stack = gettagstack(winid)
    let stack['items'] = [item]
    call settagstack(winid, stack, 't')
endfunction

function tex#vertsub(cmd, del)
    " norm! mx
    " execute('norm! f|s\r' . a:cmd . ' ')
    " execute('norm! F|s\l' . a:cmd . ' ')
    " norm! `x
    let pos = getcurpos()
    try
        try
            exe 'sub/\%<.c\(.\?\)\(\\\)\?|\([^|]*\)\2|\([a-zA-Z]\)\%>.c/\1\\l' . a:cmd . ' \3 ' . '\\r' . a:cmd . ' \4/'
        catch
            exe 'sub/\%<.c\(.\?\)\(\\\)\?|\([^|]*\)\2|\%>.c/\1\\l' . a:cmd . ' \3 ' . '\\r' . a:cmd . '/'
        endtry
    catch
        exe 'sub/\%<.c\(.\?\)\\l' . a:cmd . '[[:space:]]*\(.\{-}\)[[:space:]]*\\r' . a:cmd . '[[:space:]]*\%>.c/\1' . a:del . '\2' . a:del . '/' 
    endtry
    call setpos('.', pos)
endfunction


function tex#sync(remote)
    wall
    let msg = system("autocommit")
    if len(msg) == 0
        echo 'No changes to commit'
    else
        exe $'Dispatch! git commit -am ' . shellescape(msg)
    endif
    exe $'Dispatch! git pull {a:remote} && git push {a:remote}'
endfunction

function tex#openoverleaf(remote)
    let id = fugitive#Remote(a:remote)['path'][1:]
    call system($"open https://www.overleaf.com/project/{id}")
endfunction


function tex#overleaf()

    command! -nargs=1 Sync call tex#sync(<f-args>)

    nmap <C-S><C-P> :call tex#sync("origin")<CR>
    nmap <C-S><C-O> :call tex#openoverleaf("origin")<CR>

endfunction

function tex#main()
    exe 'edit ' . b:vimtex.tex
endfunction


function tex#resetviewer()
    wall
    let spc = trim(system('yabai -m query --spaces --window | jq ".[].index"'))
    let cmd = 'yabai -m query --windows | jq ''.[] | select(.app == "Skim" and .space != '.spc.' and (.["is-visible"] | not)) | .id'' | xargs -I{} -n1 yabai -m window {} --space '.spc.' --focus'
    call system("bash -c " . shellescape(cmd))

    call system('osascript -e "tell application \"Skim\" to activate"')

    call vimtex#compiler#start()
    call vimtex#view#view()
    " call system('osascript -e "tell application \"Skim\" to quit"')
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
    " call system('open -g "rectangle-pro://execute-layout?name=texset"')

    if n == 0
        let script =<< trim END
            tell application "System Events"
                set n to number of items in windows of application "Skim"
                set bounds of every window of application "MacVim" to {0, 38, 890, 980}

                set w to front window of application "Skim"
                set bounds of w to {890, 38, 1512, 980}
            end tell
        END
    elseif n == 1
        let script =<< trim END
            tell application "System Events"
                set n to number of items in windows of application "Skim"
                set bounds of every window of application "MacVim" to {0, 25, 1216, 1080}

                set w to front window of application "Skim"
                set bounds of w to {1216, 25, 1920, 1080}
            end tell
        END
    elseif n > 1
        let script =<< trim END
            tell application "System Events"
                set n to number of items in windows of application "Skim"

                set mv to front window of application "MacVim"
                set bounds of mv to {0, 38, 1512, 980}
                
                set w to front window of application "Skim"

                set windows_skim to windows of application "Skim"

                repeat with i from 1 to n
                    set w to item i of windows_skim
                    if i = 1 then
                        set bounds of w to {793, -1895, 1873, 0}
                    else
                        if i mod 2 = 0 then
                            set bounds of w to {-1127, -1055, -167, 0}
                        else
                            set bounds of w to {-167, -1055, 793, 0}
                        end if
                    end if
                end repeat
            end tell
        END
    endif

    call system('osascript -e ' . shellescape(join(script, "\r")))
    call system('osascript -e "tell application \"MacVim\" to activate"')
endfunction


function tex#stamp()
    return 'VM.' . systemlist('date +"%-m.%d"')[0]
endfunction

