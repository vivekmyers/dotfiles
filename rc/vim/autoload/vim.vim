fun! vim#exec(mot) 
    normal '[V']y
    let @" = substitute(@", '\<fun\k*\>\ze ', '&! ', 'g')
    @"
    echo @"->split("\n")[0]
endfun

