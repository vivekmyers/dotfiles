
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
            close
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
            close
            let @* = @* . "\n" . @s
            return @*
        else
            echo "tag from " . l:taglist[0].filename
        endif
    endif
    return ''
endfunction

   


