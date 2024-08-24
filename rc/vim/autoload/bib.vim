
function bib#addref()
    let l:pos = getpos('.')

    let l:clip = @*
    let l:bib = vimtex#bib#files()
    if l:bib == []
        echoerr "no bib file found"
        return
    endif
    let l:bib = l:bib[0]

    let entries = split(l:clip, '\n\n')
    let bibkeys = []
    for entry in entries
        let bibkey = matchstr(entry, '[[:space:]]*@[[:alnum:]]\+{\zs[^,]*\ze,')
        if bibkey == ''
            echoerr "invalid bib entry"
        else
            echo bibkey
            if taglist('^' . bibkey . '$') != []
                echoerr "duplicate key " . bibkey
                return
            endif
        endif
    endfor


    if match(l:clip, '^\([[:space:]]*@[[:alnum:]]\+{.*}\)\+[[:space:]]*$') == -1
        echoerr "invalid bib entry"
    else
        exe $'vnew {l:bib}'
        exe "normal Go\e"
        let l:pos = getpos('.')
        silent! put =l:clip
        call setpos('.', l:pos)
        normal zz
        match DiffAdd /\%>.l.*/
    endif
endfunction

function bib#tryadd(entry)
    let l:pos = getpos('.')

    let l:bib = vimtex#bib#files()
    if l:bib == []
        echoerr "no bib file found"
        return
    endif
    let l:bib = l:bib[0]

    let entries = split(a:entry, '\n\n')
    let bibkeys = []
    for entry in entries
        let bibkey = matchstr(entry, '[[:space:]]*@[[:alnum:]]\+{\zs[^,]*\ze,')
        if bibkey == ''
            echoerr "invalid bib entry " . a:entry
            return
        else
            if taglist('^' . bibkey . '$') != []
                return
            endif
        endif
    endfor


    if match(a:entry, '^\([[:space:]]*@[[:alnum:]]\+{.*}\)\+[[:space:]]*$') > -1
        exe $'vnew {l:bib}'
        exe "normal Go\e"
        let l:pos = getpos('.')
        silent! put =a:entry
        call setpos('.', l:pos)
        normal zz
        match DiffAdd /\%>.l.*/
    endif
endfunction

function bib#clean()
    
    exe '%!biber --tool --output_align --output-legacy-dates --output_indent=2 --output_fieldcase=lower -q -O - %'
    normal G

    while search('@', 'bW') != 0

        let l:start = getpos('.')
        let l:view = winsaveview()
        let l:start[0] = bufnr('%')
        normal f{e
        call bib#dedup(0)

        silent! normal yip
        if @" =~ '\<journaltitle\>' && @" !~ '\<journal\>'
            exe "normal vip:s/journaltitle/journal/e\<cr>"
        endif
        exe "normal vip:normal gww\<cr>"

        call winrestview(l:view)
        call setpos('.', l:start)
    endwhile


    normal gggaG=


endfunction
        


function bib#dedup(inter)
    let key = expand('<cword>')
    let options = s:duplicates(key, 0, a:inter)
    if len(options) < 2
        if a:inter
            echo "No duplicates found"
        endif
    else
        call sort(options)
        call uniq(options)
        let Choices = { A, L, P -> options }
        if len(options) == 1
            let choice = options[0]
        else
            call inputsave()
            let choice = input('Choose key to keep: ', key, 'customlist,Choices')
            call inputrestore()
        endif
        if choice != ''
            call s:duplicates(choice, 1, a:inter)
        endif
    endif
endfunction

function s:duplicates(key, do, inter)
    let key = a:key
    let l:title = bib#title(key)->tolower()->trim()

    let found = []


    let l:bib = vimtex#bib#files()
    if l:bib == []
        echoerr "no bib file found"
        return
    endif
    for bib in l:bib
        let l:bib = bib
        let l:bufnrstart = bufnr()
        let l:view = winsaveview()
        let l:pos = getpos('.')
        let duplicate_count = 0
        let substitute_count = 0

        silent! exe 'new ' . l:bib
        " echom 'Looking for key ' . key . ' in ' . l:bib

        call cursor(1, 1)
        
        while line('.') < line('$')
            let l:start = getpos('.')
            silent! normal! yap
            let entry = @"->trim()
            let bibkey = matchstr(entry, '[[:space:]]*@[[:alnum:]]\+{\zs[^,]*\ze,')

            if bibkey == ''
                if search('@', 'W') == 0
                    break
                else
                    continue
                endif
            endif


            call search('\<title\>', 'cW')
            call search('[{"]', 'cW')
            let del = strcharpart(getline('.')[col('.') - 1:], 0, 1)

            call setpos("'a", getpos('.'))

            if del == '{'
                call searchpair('{', '', '}', 'W')
            else
                call search('.', 'W')
                call search('"', 'W')
            endif

            call setpos("'b", getpos('.'))
            silent! normal! `ay`b
            let l:entry = getreg('"')

            call setpos("'a", getpos("'a"))
            call setpos("'b", getpos("'b"))

            let l:entry = substitute(l:entry, '[{}"\n]', '', 'g')
            let l:entry = substitute(l:entry, '  *', ' ', 'g')
            let l:entry = substitute(l:entry, '^ *', '', 'g')
            let l:entry = substitute(l:entry, ' *$', '', 'g')
            let l:entry = l:entry->tolower()->trim()

            if l:entry == l:title && ( bibkey != key || found->index(key) != -1 )
                if duplicate_count == 0 && a:do && a:inter
                    Git add -u
                endif
                let duplicate_count += 1
                let bufnr = bufnr()
                if a:do
                    let pos = getpos('.')
                    try
                        exe 'vimgrep! /' . bibkey . '/gj **/*.tex'
                        exe 'cdo! s/'. bibkey .'/'. key .'/ge'
                        let ndup = len(getqflist())
                    catch
                        let ndup = 0
                    endtry
                    let substitute_count += ndup
                    echom 'Renaming duplicate '.bibkey.'->'.key.', replaced '.ndup.' references'
                    exe 'buf ' . bufnr
                    call setpos('.', pos)
                    silent! normal! dap
                endif
            endif

            if l:entry == l:title
                let found += [bibkey]
            endif


            call setpos('.', l:start)
            +1

            if search('@', 'W') == 0
                break
            endif
        endwhile

        close!
        exe 'buf ' . l:bufnrstart
        call setpos('.', l:pos)
        call winrestview(l:view)

        " if a:do
        "     silent! wall
        " endif

        if a:do && a:inter
            if duplicate_count == 0 
                echom "No duplicates found"
            else
                vert Git diff
            endif
        endif
    endfor

    return found
endfunction



function bib#updateref(entries)
    let l:pos = getpos('.')

    let l:bib = vimtex#bib#files()
    if l:bib == []
        echoerr "no bib file found"
        return
    endif
    let l:bib = l:bib[0]

    exe $'vnew {l:bib}'
    let entries = split(a:entries, '\n\n')
    let bibkeys = []
    for entry in entries
        let bibkey = matchstr(entry, '[[:space:]]*@[[:alnum:]]\+{\zs[^,]*\ze,')
        if bibkey == ''
            echoerr "invalid bib entry"
        else
            let l:tag = taglist('^' . bibkey . '$')
            if l:tag != []
                silent! exe l:tag[0].cmd
                silent! exe 'normal! dap'
            endif
        endif
    endfor
    close!


    if match(a:entries, '^\([[:space:]]*@[[:alnum:]]\+{.*}\)\+[[:space:]]*$') == -1
        echoerr "invalid bib entry"
    else
        exe $'vnew {l:bib}'
        exe "normal Go\e"
        let l:pos = getpos('.')
        silent! put =entries
        call setpos('.', l:pos)
        normal zz
        match DiffAdd /\%>.l.*/
    endif
endfunction

function bib#open()
    let l:bib = vimtex#bib#files()
    if l:bib == []
        echoerr "no bib file found"
        return
    endif
    let l:bib = l:bib[0]
    exe $'vnew {l:bib}'
endfunction


function bib#copy()
    let l:tag = expand('<cword>')
    let l:taglist = taglist('^' . l:tag . '$')
    if l:taglist == []
        echo "no tag found for " . l:tag
    else
        if l:taglist[0].filename =~ '\.bib$'
            let l:pos = getcharpos('.')
            let l:view = winsaveview()
            let l:pos[0] = bufnr('%')
            exe 'new ' . l:taglist[0].filename
            exe l:taglist[0].cmd
            normal! "*yip
            close!
            nnoremap <buffer> <cr> :call bib#append()<cr>
            echo @*
            return @*
        else
            echo "tag from " . l:taglist[0].filename
        endif
    endif
    return ''
endfunction

   
function bib#append()
    let l:tag = expand('<cword>')
    let l:taglist = taglist('^' . l:tag . '$')
    if l:taglist == []
        echo "no tag found for " . l:tag
    else
        if l:taglist[0].filename =~ '\.bib$'
            let l:pos = getcharpos('.')
            let l:view = winsaveview()
            let l:pos[0] = bufnr('%')
            exe 'new ' . l:taglist[0].filename
            exe l:taglist[0].cmd
            normal! "syip
            close!
            let @* = @* . "\n" . @s
            return @*
        else
            echo "tag from " . l:taglist[0].filename
        endif
    endif
    return ''
endfunction

   
function bib#title(key)
    let l:tag = a:key
    let l:taglist = taglist('^' . l:tag . '$')
    if l:taglist == []
        echoerr "no tag found for " . l:tag
    else
        if l:taglist[0].filename =~ '\.bib$'
            let l:pos = getcharpos('.')
            let l:view = winsaveview()
            let l:pos[0] = bufnr('%')
            exe 'new ' . l:taglist[0].filename
            exe l:taglist[0].cmd

            let a0 = getpos("'a")
            let b0 = getpos("'b")
            let s0 = getreginfo('@')

            call search('\<title\>', 'cW')
            call search('[{"]', 'cW')
            let del = strcharpart(getline('.')[col('.') - 1:], 0, 1)


            call setpos("'a", getpos('.'))

            if del == '{'
                call searchpair('{', '', '}', 'W')
            else
                call search('.', 'W')
                call search('"', 'W')
            endif

            call setpos("'b", getpos('.'))
            silent! normal! `ay`b
            let l:title = getreg('"')

            call setpos("'a", a0)
            call setpos("'b", b0)
            call setreg('@', s0)

            close!
            call setpos('.', l:pos)
            call winrestview(l:view)
            let l:title = substitute(l:title, '[{}"\n]', '', 'g')
            let l:title = substitute(l:title, '  *', ' ', 'g')
            let l:title = substitute(l:title, '^ *', '', 'g')
            let l:title = substitute(l:title, ' *$', '', 'g')
            redraw
            if l:title == ''
                echoerr "no title found"
            else
                return l:title
            endif
        else
            echoerr "tag from " . l:taglist[0].filename
        endif
    endif
    return ''
endfunction

