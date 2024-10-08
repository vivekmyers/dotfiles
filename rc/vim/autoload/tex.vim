
let g:tex_comment_regex = '\(^[[:space:]]*\)\@<=\(%%\|    \)[[:space:]]*[A-Z][A-Z]\(\.[0-9]*\)*\|\\todo\>\|\<TODO\>'
let g:tex_comment_people =<< trim END
    vivek
    adnote
    kuan
    anca
    sergey
    ben
    billz
    dorsa
    michal
    kucil
END

let g:exclude_regex = '\[resolved.*\]\|^[[:space:]]*\\def\|^[[:space:]]*\\[[:alpha:]]*command'

let g:comment_regex = g:tex_comment_regex
for person in g:tex_comment_people
    let g:comment_regex = g:comment_regex . '\|\\' . person . '\>'
endfor
let g:comment_regex = '\(^[^%]*\)\@<=\(' . g:comment_regex . '\)'


function tex#comment_regex()
    return g:comment_regex
endfunction

function tex#comments(filter = '')
    let prg = 'git grep -nI '
        \ . shellescape(substitute(g:comment_regex, '\\@<=', '', 'g'))
        \ . ' | grep -v ' . shellescape(g:exclude_regex)
    if a:filter != ''
        let l:prg = l:prg . ' | grep ' . shellescape(a:filter)
    endif
    exe 'Grepper -noprompt -tool git -grepprg ' . prg
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
    if search('\[resolved.*\]', 'c', line('.')) == line('.')
        call tex#unresolve()
    else
        call tex#resolve()
    endif
endfunction

function tex#nextcomment()
    let pos = getcurpos()
    call search(g:comment_regex, 'W')
    while getline('.') =~ g:exclude_regex
        if search(g:comment_regex, 'W') == 0
            call setpos('.', pos)
            break
        endif 
    endwhile
endfunction

function tex#prevcomment()
    let pos = getcurpos()
    call search(g:comment_regex, 'bW')
    while getline('.') =~ g:exclude_regex
        if search(g:comment_regex, 'bW') == 0
            call setpos('.', pos)
            break
        endif
    endwhile
endfunction

function tex#resolve()
    let l:line = line('.')
    let l:mark = "[resolved: ".tex#stamp()."]"
    let l:match = matchstr(getline('.'), g:comment_regex)
    if l:match !~ '%'
        execute 'substitute/'.g:comment_regex.'/%&'.l:mark.'/'
    else
        execute 'substitute/'.g:comment_regex.'/&'.l:mark.'/'
    endif
endfunction

function tex#unresolve()
    let l:line = line('.')
    execute 'substitute/\[resolved.*\]//'
    if substitute(getline('.'), '%', '', '') =~ g:comment_regex
        execute 'substitute/%//'
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
    if exists('b:vimtex.tex')
        exe 'edit ' . b:vimtex.tex
    else
        let l:tex = glob('*.tex', 0, 1)
        if len(l:tex) == 0
            echo 'No TeX file found'
            return
        endif
        exe 'edit ' . l:tex[0]
        if exists('b:vimtex')
            exe 'edit ' . b:vimtex.tex
        endif
    endif
endfunction


function tex#resetviewer(compile)
    wall
    let spc = trim(system('yabai -m query --spaces --window | jq ".[].index"'))
    let cmd = 'yabai -m query --windows | jq ''.[] | select(.app == "Skim" and .space != '.spc.' and (.["is-visible"] | not)) | .id'' | xargs -I{} -n1 yabai -m window {} --space '.spc.' --focus'
    call system("bash -c " . shellescape(cmd))

    let script =<< trim END
        tell application "System Events"
            activate application "Skim"
            key code 36
        end tell
    END
    call system('osascript -e ' . shellescape(join(script, "\r")))

    if a:compile
        call vimtex#compiler#start()
    endif
    call tex#view()
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
        " call system('osascript -e ' . shellescape(join(script, "\r")))
    elseif n > 1
        let script =<< trim END
            tell application "System Events"
                set n to number of items in windows of application "Skim"

                set mv to front window of application "MacVim"
                set bounds of mv to {0, 38, 1514, 980}
                
                set w to front window of application "Skim"

                set windows_skim to windows of application "Skim"

                repeat with i from 1 to n
                    set w to item i of windows_skim
                    if i = 1 then
                        set bounds of w to {770, -1895, 1850, 0}
                    else
                        if i mod 2 = 0 then
                            set bounds of w to {-1150, -1055, -190, 0}
                        else
                            set bounds of w to {-190, -1055, 770, 0}
                        end if
                    end if
                end repeat
            end tell
        END
        " let script =<< trim END
        "     mvid=$(yabai -m query --windows | jq '[.[] | select(.app=="MacVim")] | first | .id')
        "     skimid=$(yabai -m query --windows | jq '[.[] | select(.app=="Skim")] | first | .id')
        "     evenid=( $(yabai -m query --windows | jq '[.[] | select(.app=="Skim")] | to_entries | .[1:].[] | select(.key % 2 == 0) | .value.id') )
        "     oddid=(  $(yabai -m query --windows | jq '[.[] | select(.app=="Skim")] | to_entries | .[1:].[] | select(.key % 2 == 1) | .value.id') )
        "     yabai -m window "$mvid" --grid 1:1:0:0:1:1 
        "     yabai -m window "$mvid" --grid 1:1:0:0:1:1 
        "     yabai -m window "$skimid" --grid 1:1:0:0:1:1
        "     yabai -m window "$skimid" --grid 1:1:0:0:1:1 
        "     for i in "${evenid[@]}"; do
        "         yabai -m window "$i" --grid 1:2:0:0:1:1 
        "     done
        "     for i in "${oddid[@]}"; do
        "         yabai -m window "$i" --grid 1:2:0:1:1:1 
        "     done
        " END
        " call system('bash -c ' . shellescape(join(script, "\n")))
    endif

    call system('osascript -e ' . shellescape(join(script, "\r")))
    call system('osascript -e "tell application \"MacVim\" to activate"')
endfunction


function tex#stamp()
    return 'VM.' . systemlist('date +"%-m.%d"')[0]
endfunction


function tex#view()
    let l:pdf = b:vimtex.viewer.out()
    call system('pdfinfo ' . l:pdf)
    if v:shell_error == 0
        VimtexView
    else
        echo 'Invalid PDF file'
    endif
endfunction
