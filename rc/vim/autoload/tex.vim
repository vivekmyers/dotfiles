
let g:tex_comment_regex = '\(^[[:space:]]*\)\@<=%%[[:space:]]*[A-Z]\.\?[A-Z]\(\.[0-9]*\)*\(\W\)\@=\|\\todo\>\|\<TODO\>\|^[[:space:]]\+[A-Z][A-Z]\(\W\)\@='
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
    cathy
END

let g:exclude_regex = '\[resolved.*\]\|^[[:space:]]*\\def\|^[[:space:]]*\\[[:alpha:]]*command'

let g:comment_regex = g:tex_comment_regex
for person in g:tex_comment_people
    let g:comment_regex = g:comment_regex . '\|\\' . person . '{\@='
endfor
let g:comment_regex = '\(^[^%]*\)\@<=\(' . g:comment_regex . '\)'


fun tex#comment_regex()
    return g:comment_regex
endfun

fun tex#comments(filter = '')
    let prg = 'git grep -nI '
                \ . shellescape(substitute(g:comment_regex, '\\@<\?=', '', 'g'))
                \ . ' | grep -v ' . shellescape(g:exclude_regex)
    if a:filter != ''
        let l:prg = l:prg . ' | grep ' . shellescape(a:filter)
    endif
    exe 'Grepper -noprompt -tool git -grepprg ' . prg
endfun

fun tex#togmark()
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
endfun

fun tex#togresolve()
    if search('\[resolved.*\]', 'c', line('.')) == line('.')
        call tex#unresolve()
    else
        call tex#resolve()
    endif
endfun

fun tex#nextcomment()
    let pos = getcurpos()
    call search(g:comment_regex, 'W')
    while getline('.') =~ g:exclude_regex
        if search(g:comment_regex, 'W') == 0
            call setpos('.', pos)
            break
        endif
    endwhile
endfun

fun tex#prevcomment()
    let pos = getcurpos()
    call search(g:comment_regex, 'bW')
    while getline('.') =~ g:exclude_regex
        if search(g:comment_regex, 'bW') == 0
            call setpos('.', pos)
            break
        endif
    endwhile
endfun

fun tex#resolve()
    let l:line = line('.')
    let l:mark = "[resolved: ".tex#stamp()."]"
    let l:match = matchstr(getline('.'), g:comment_regex)
    if l:match !~ '%'
        execute 'substitute/'.g:comment_regex.'/%&'.l:mark.'/'
    else
        execute 'substitute/'.g:comment_regex.'/&'.l:mark.'/'
    endif
endfun

fun tex#unresolve()
    let l:line = line('.')
    execute 'substitute/\[resolved.*\]//'
    if substitute(getline('.'), '%', '', '') =~ g:comment_regex
        execute 'substitute/%//'
    endif
endfun

fun tex#getpack()
    let l:pack = systemlist('sed -n "s/.*\\usepackage{\(.*\)}.*/\1/p" ' . join(glob('*.tex', 0, 1), ' '))
    return l:pack
endfun

fun tex#showdef()
    let l:cmd = expand('<cword>')
    let l:result = system('latexdef -sF -p ' . join(tex#getpack(), ' -p ') . ' ' . l:cmd)
    echo l:result
endfun

fun tex#gotodef()
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
endfun

fun tex#vertsub(cmd, del)
    " norm! mx
    " execute('norm! f|s\r' . a:cmd . ' ')
    " execute('norm! F|s\l' . a:cmd . ' ')
    " norm! `x
    let pos = getcurpos('.')
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
endfun

fun Texdoneover(remote)
    if g:asyncrun_code != 0
        echom $'Failed: git push {a:remote}'
        copen
    else
        " echom $'Success: git push {a:remote}'
        echom $'All synced with ' . a:remote
        cclose
    endif
endfun

fun Texpull(remote)
    if g:asyncrun_code != 0
        echom $'Failed: git commit'
        copen
    else
        " echom $'Success: !git commit'
        echom '!git pull ' . a:remote . ' (running...)'
        let g:asyncrun_code = 0
        call timer_start(1000, {tid -> execute($'AsyncRun -post=call\ Texpush("{a:remote}") git pull {a:remote}') })
    endif
endfun

fun Texpush(remote)
    if g:asyncrun_code != 0
        echom 'Failed: !git pull ' . a:remote
        copen
    else
        " echom 'Success: !git pull ' . a:remote
        echom '!git push ' . a:remote . ' (running...)'
        call timer_start(1000, {tid -> execute($'AsyncRun -post=call\ Texdoneover("{a:remote}") git pull {a:remote}') })
    endif
endfun

fun tex#sync(remote)
    wall
    copen
    let g:asyncrun_code = 0
    let msg = system("autocommit")
    redraw!
    if len(msg) == 0
        call Texpull(a:remote)
    else
        echom '!git commit -am ' . shellescape(msg) . ' (running...)'
        exe $'AsyncRun -post=call\ Texpull("{a:remote}") git commit -am ' . shellescape(msg)
    endif
endfun

fun tex#openoverleaf(remote)
    let id = fugitive#Remote(a:remote)['path'][1:]
    call system($"open https://www.overleaf.com/project/{id}")
endfun


fun tex#overleaf()

    command! -nargs=1 Sync call tex#sync(<f-args>)

    nmap <C-S><C-P> :call tex#sync("origin")<CR>
    nmap <C-S><C-O> :call tex#openoverleaf("origin")<CR>
    command! Figs silent! !open resources/figures.key

endfun

fun tex#main()
    let l:tex = systemlist('ls -t *.tex')
    if len(l:tex) == 0
        echo 'No TeX file found'
        return
    endif
    exe 'edit ' . l:tex[0]
    if exists('b:vimtex')
        exe 'edit ' . b:vimtex.tex
    endif
endfun


fun tex#viewer_layout(compile)
    wall
    let $FOCUS_SKIM = 'x="$(yabai -m query --spaces --window | jq ".[].index")";yabai -m query --windows | jq ''.[] | select(.app == "Skim" and .space != ''"$x"'' and (.["is-visible"] | not)) | .id'' | xargs -I{} -n1 yabai -m window {} --space ''"$x"'' --focus;'


    let script =<< trim END
        tell application "System Events"
            activate application "Skim"
            keystroke return
        end tell
    END

    let $FOCUS_SKIM .= 'osascript -e ' . shellescape(join(script, "\r"))

    silent! exe "Dispatch! eval $FOCUS_SKIM"

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

    " call system('open -g "rectangle-pro://execute-layout?name=texset"')
    let script = 'n=$(osascript -e ' . shellescape(join(script, "\n")) . ');'
    if exists('g:tex_displays')
        let script = 'n=' . g:tex_displays . ';'
    endif
    let switch =<< trim END
        case $n in
        0) osascript -e '
        tell application "System Events"
            set n to number of items in windows of application "Skim"
            set bounds of every window of application "MacVim" to {0, 38, 890, 980}

            set w to front window of application "Skim"
            set bounds of w to {890, 38, 1512, 980}
        end tell
        ';;
        1) osascript -e '
        tell application "System Events"
            set n to number of items in windows of application "Skim"
            set bounds of every window of application "MacVim" to {0, 25, 1216, 1080}

            set w to front window of application "Skim"
            set bounds of w to {1216, 25, 1920, 1080}
        end tell
        ';;
        *) osascript -e '
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
        ';;
        esac
    END
    let script = script . join(switch, "\n")

    let $RESIZE_WINDOWS = script

    silent! exe 'Dispatch! eval $RESIZE_WINDOWS'
    let $FOCUS_VIM = 'yabai -m query --windows | jq ''[.[] | select(.app == "MacVim") | .id] | first'' | xargs -I{} -n1 yabai -m window {} --focus'
    exe 'Dispatch! eval $FOCUS_VIM'
endfun


fun tex#stamp()
    return 'VM.' . systemlist('date +"%-m.%d"')[0]
endfun


fun tex#view()
    let l:pdf = b:vimtex.viewer.out()
    call system('pdfinfo ' . l:pdf)
    if v:shell_error == 0
        VimtexView
    else
        echo 'Invalid PDF file'
    endif
endfun

fun tex#runpdf()
    call system('mkdir -p build')
    call system('rm -f build/' . expand('%:t:r') . '.*')
    exe 'vert Start latexmk -f -g % -file-line-error -shell-escape -outdir=build -auxdir=build -pdf'
endfun

fun tex#compilepdf()
    call system('mkdir -p build')
    call system('rm -f build/' . expand('%:t:r') . '.*')
    exe 'vert Dispatch! latexmk -f -g % -file-line-error -interaction=batchmode -shell-escape -outdir=build -auxdir=build -pdf; open -a Skim build/'.shellescape(expand('%:t:r')).'.pdf'
endfun

fun! tex#percentify(motion)
    if line(''']')==line('''[') || !line(''']') || !line('''[')
        substitute/%*$/%/e
    else
        try
            exe "'[,']-1 s/%*$/%/e"
        catch
            substitute/%*$/%/e
        endtry
    endif
endfun

fun tex#breakcomma(motion)
    if line(''']')>line('''[')
        exe "'[,']-1 join"
    endif
    let first = 1
    while getline('.') =~ '[,;]' && getline('.')->len() > 80
        exe "silent! normal 80|F,wi\<cr>"
        if first
            normal >>
        endif
        let first = 0
    endwhile
endfun


fun tex#sentencebreak(start, end)
    if mode() == 'n'
        let pos = getcurpos()
        call feedkeys('m]m[')
        let last = match(getline(a:start), '%')
        if last == -1
            let last = getline(a:start)->len()
        endif
        silent! call feedkeys(':'.a:start.','.a:end.'s/\%<'.last.'c[.!?]\zs[[:space:]]\+\($\)\@!/\r/ge')
        " call feedkeys('gp=gp:norm `>gwwkm>')
        call feedkeys('gp=')
        silent! call feedkeys(':noh|echo ""')
        call setpos('.', pos)
    endif
endfun

fun tex#inenv(n)
    let pos = vimtex#env#is_inside(a:n)
    return (pos[0]!=0)||(pos[1]!=0)
endfun

fun tex#align_cut()
    if !vimtex#syntax#in_mathzone()
        echoerr "Not in mathzone"
        return
    endif
    let extra = ''
    let lno = line('.')

    let view = winsaveview()
    if tex#inenv('equation')
        call vimtex#env#change_surrounding('math', 'align')
    elseif tex#inenv('equation*')
        call vimtex#env#change_surrounding('math', 'align*')
    elseif !tex#inenv('align')
        call vimtex#env#change_surrounding('math', 'align*')
    endif
    if tex#inenv("align") && getline('.') !~ '\\nonumber'
        let extra = '\nonumber'
    endif
    exe lno.'s/^[^&{]*\zs=\ze[^&]*$/\&=/e'

    call winrestview(view)
    star
    call feedkeys(' '.extra.'\\*'."\<cr>".'&\mspace{100mu} ')
endfun

fun tex#align_newline()
    if !vimtex#syntax#in_mathzone()
        echoerr "Not in mathzone"
        return
    endif


    let view = winsaveview()
    let extra = ''

    if tex#inenv('equation')
        call vimtex#env#change_surrounding('math', 'align')
    elseif tex#inenv('equation*')
        call vimtex#env#change_surrounding('math', 'align*')
    elseif !tex#inenv('align')
        call vimtex#env#change_surrounding('math', 'align*')
    endif
    if tex#inenv("align") && getline('.') !~ '\\nonumber'
        let extra = '\nonumber'
    endif
    exe 's/^[^&]*\zs=\ze[^&]*$/\&=/e'

    call winrestview(view)
    star!
    call feedkeys(' '.extra.'\\'."\<cr>".'&= ')
endfun

fun tex#addimport()
    let arg = input('package: ')

    let cmd = '\usepackage{'.arg.'}'

    if search(escape(cmd, '\') . '[[:space:]]*$', 'cbn') != 0
        echoerr 'Already imported'
        return
    endif

    let iline = search('^\\usepackage', 'cbn')
    call append(iline, cmd)

    if line('.') > iline + 35
        split
        call cursor(iline + 1, 1)
    else
        normal! zb
    endif
endfun

fun tex#abstract()
    call tex#main()
    !pandoc -s % -o out.txt
    !perl -pi -e 's/{[^{]*}//g and redo' out.txt
    !perl -pi -e 's/\[([^\[]*)\]/\1/g and redo' out.txt
    !perl -pi -e 's/\[([^\[]*)\]/\1/g and redo' out.txt
    !perl -pi -e 's/\^\d+//g and redo' out.txt
    edit! out.txt
    call search('abstract')
    +1
    normal "*yii
    let @* = @*->substitute('[[:space:]]\+', ' ', 'g')->trim()
    Remove
    bd
endfun

fun tex#title()
    call tex#main()
    !pandoc -s % -o out.txt
    edit out.txt
    let @* = system('perl -ne ''/title:/ and $s=1 or (/^---/ and $s=0); $s==1 and {$x.=$_}; END {$_=$x; s/\R/ /g; s/[[:space:]]+/ /g; m/title: "(.*)"/ or m/title: (.*)/; print $1}'' out.txt')
    Remove
    bd
    echo @*
endfun

fun tex#movealign()
    if tex#inenv("align") || tex#inenv("align*")
        let curpos = getcurpos()
        s/&//ge
        call setpos('.', curpos)
        normal i&
    endif
endfun


fun tex#align()
    " normal va$o
    if !vimtex#syntax#in_mathzone()
        echoerr "Not in mathzone"
        return
    endif
    let pos = getcurpos()
    exe "normal vi$:retab\<cr>"
    call setpos(".",pos)
    normal vi$:s/\\begin{align\*\?}\ze.*\S/&\r/ge
    call setpos(".",pos)
    normal vi$:s/\S.*\zs\\end{align\*\?}/\r&/ge
    call setpos(".",pos)
    exe "normal vi$:s/\\s\\+/ /ge\<cr>"
    call setpos(".",pos)
    exe "normal vi$:g/[^ %][^%]*\\zs&/s/&/\\r&/ge\<cr>"
    call setpos(".",pos)
    exe "normal vi$:s/&\\s\\+/\\&/ge\<cr>"
    exe "normal vi$:s/&=\\s*/\\&= /ge\<cr>"
    call setpos(".",pos)
    normal vi$:g/^[^%]*\zs\\\\\*\?\ze.*[^ *]/v/\[-\?\d\+.\?.\?\]/s//&\r/ge
    setlocal tw=100
    call setpos(".",pos)
    normal vi$:g/./normal '>gwwkm>
    call setpos(".",pos)
    normal vi$:g/^[[:space:]]*$/d
    exe "normal va$\<esc>"
    let indentlevel = indent(line("'<"))
    call setpos(".",pos)
    exe "normal vi$:left\<cr>"
    call setpos(".",pos)
    exe 'normal vi$:v/&/normal V'.(indentlevel/4+2).'>'
    call setpos(".",pos)
    exe 'normal vi$:g/&/normal V'.(indentlevel/4+1).'>'
    call setpos(".",pos)
    exe 'normal vi$:g/&\\mspace/normal V1>'
    exe 'normal vi$:g/^\s*\\\(def\|intertext\)/normal V1<'
    normal va$ojV:v/&/normal <<
    call setpos(".",pos)
    normal va$k:s/\\\\$//e
    noh
endfun
