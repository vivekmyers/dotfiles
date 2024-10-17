function zotero#select()
    let l:title = zotero#copyref()
    if l:title == ''
        return
    endif
    let l:title = l:title[:30]
    let l:pat = substitute(l:title, '[^a-zA-Z0-9]', '*', 'g')
    let l:pdf = systemlist('find ~/Zotero/storage -iname '.shellescape('*' . l:pat . '*.pdf'))
    if l:pdf != []
        let l:ids = map(l:pdf, {key, val -> matchstr(val, '[^/]\+\ze/[^/]\+\.pdf')})
        for id in l:ids
            silent! call system('open zotero://select/library/items/' . id)
        endfor
    endif
endfunction

function zotero#openref()
    let l:title = zotero#copyref()
    if l:title == ''
        return
    endif
    let l:title = l:title[:30]
    let l:pat = substitute(l:title, '[^a-zA-Z0-9]', '*', 'g')
    let l:pdf = systemlist('find ~/Zotero/storage -iname '.shellescape('*' . l:pat . '*.pdf'))
    if l:pdf != []
        silent! call system('open -a Skim "' . l:pdf[0] . '"')
    endif
endfunction

function zotero#copyref()
    let l:tag = expand('<cword>')
    let l:title = bib#title(l:tag)
    echo l:title
    let @* = l:title
    return l:title
endfunction

function zotero#cite()
    let focused = system('yabai -m query --windows --window | jq -r ".id"')
    let api_call = 'http://127.0.0.1:23119/better-bibtex/cayw?format=translate&translator=bibtex'
    silent! let entry = system('curl -s '.shellescape(api_call))
    try
        let ref = entry->split()->map({_, val -> matchstr(val, '[[:space:]]*@[[:alnum:]]\+{\zs[^,]*\ze,')})->filter({_, val -> val != ''})->join(',')
        let g:zotero_added = entry
        call system('yabai -m window --focus ' . focused)
        return ref
    catch
        let g:zotero_added = ''
        return ''
    endtry
endfunction

function zotero#import()
    let focused = system('yabai -m query --windows --window | jq -r ".id"')
    let api_call = 'http://127.0.0.1:23119/better-bibtex/cayw?format=translate&translator=bibtex'
    let entry = system('curl -s '.shellescape(api_call))
    call system('yabai -m window --focus ' . focused)
    call bib#updateref(entry)
endfunction
