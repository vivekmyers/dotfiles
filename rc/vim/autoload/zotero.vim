function zotero#select()
    let l:title = zotero#copyref()
    if l:title == ''
        return
    endif
    let l:pat = substitute(l:title[:30], '[^a-zA-Z0-9]', '*', 'g')
    let l:pdf = systemlist('find ~/Zotero/storage -iname "*' . l:pat . '*.pdf"')
    if l:pdf != []
        let l:id = matchstr(l:pdf[0], '[^/]\+\ze/[^/]\+\.pdf')
        silent! call system('open zotero://select/library/items/' . l:id)
    endif
endfunction

function zotero#openref()
    let l:title = zotero#copyref()
    if l:title == ''
        return
    endif
    let l:pat = substitute(l:title[:30], '[^a-zA-Z0-9]', '*', 'g')
    let l:pdf = systemlist('find ~/Zotero/storage -iname "*' . l:pat . '*.pdf"')
    if l:pdf != []
        silent! call system('open -a Skim "' . l:pdf[0] . '"')
    endif
endfunction

function zotero#copyref()
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
            exe 'edit ' . l:taglist[0].filename
            exe l:taglist[0].cmd

            let a0 = getpos("'a")
            let b0 = getpos("'b")
            let s0 = getreginfo('@')

            call search('title', 'cW')
            call search('[{"]', 'cW')
            let del = strcharpart(getline('.')[col('.') - 1:], 0, 1)

            call search('.', 'W')

            call setpos("'a", getpos('.'))
            
            if del == '{'
                call searchpair('{', '', '}', 'W')
            else
                call search('"', 'W')
            endif

            call setpos("'b", getpos('.'))
            normal! `ay`b
            let l:title = getreg('"')

            call setpos("'a", a0)
            call setpos("'b", b0)
            call setreg('@', s0)

            close
            call setpos('.', l:pos)
            call winrestview(l:view)
            let l:title = substitute(l:title, '[{}\n]', '', 'g')
            let l:title = substitute(l:title, '  *', ' ', 'g')
            let l:title = substitute(l:title, '^ *\| $\|"', '', 'g')
            redraw
            if l:title == ''
                echo "no title found"
            else
                echo l:title
                let @* = l:title
                return @*
            endif
        else
            echo "tag from " . l:taglist[0].filename
        endif
    endif
    return ''
endfunction


