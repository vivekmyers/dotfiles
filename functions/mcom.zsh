tmp=$(git status --porcelain | awk '
    $1=="M" { mod[m++]= $2 }
    $1=="R" { mod[m++]= $2 }
    $1=="A" { add[a++]= $2 }
    $1=="D" { del[d++]= $2 }
    END {
        if (a>1) {
            printf "Added: "
            for (i=0;i<a-1;i++) {
                printf (a>2?"%s, ":"%s "), add[i]
            }
            printf "and %s; ", add[i]
        } else if (a==1) {
            printf "Added: %s", add[0]
            if (m>0 || d>0) {
                printf "; "
            }
        }
        if (d>1) {
            printf "Deleted: "
            for (i=0;i<d-1;i++) {
                printf (d>2?"%s, ":"%s "), del[i]
            }
            printf "and %s; ", del[i]
        } else if (d==1) {
            printf "Deleted: %s", del[0]
            if (m>0) {
                printf "; "
            }
        }
        if (m>1) {
            printf "Modified: "
            for (i=0;i<m-1;i++) {
                printf (m>2?"%s, ":"%s "), mod[i]
            }
            printf "and %s; ", mod[i]
        } else if (m==1) {
            printf "Modified: %s", mod[0]
        }
    }
' | sed 's/;[^;]*$//')
test -n "$tmp" && git commit -am "$tmp"
