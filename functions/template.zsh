
local xflags=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -f)
            local FORCE=1
            shift
            ;;
        -*)
            xflags+=( $(perl -e '$_=shift;s/^--/-/;print' -- $1) )
            shift
            ;;
        *)
            if [[ -z "$template_src" ]]; then
                local template_src=$HOME/templates/$1
            else
                if [[ -z "$project_name" ]]; then
                    local project_name=$(realpath $1)
                else
                    echo "Error: extra positional argument $1"
                    return 1
                fi
            fi
            shift
            ;;
    esac
done

if [[ -z "$FORCE" ]]; then
    local RFLAGS="--ignore-existing"
else
    local RFLAGS=
fi

if [[ -z "$project_name" ]]; then
    local project_name=$PWD
fi

if [[ ! -d $template_src ]]; then
  echo "Error: $template_src missing"
  return 1
fi

if [[ ! -d $project_name ]]; then
    mkdir $project_name || { echo "Error: failed to create directory $project_name"; return 1; }
fi

( cd $template_src && git ls-files | xargs -I {} rsync $=RFLAGS -Raiz --exclude='init.zsh' {} $project_name/ ) || { 
    echo "Error: failed to copy files"
    return 1
}

if [[ ! -f $project_name/.projections.json ]]; then
    echo "{}" > $project_name/.projections.json
fi

( cd $template_src && git ls-files ) | while read file; do
    cat $project_name/.projections.json | jq --arg file $file --arg src $template_src '.[$file] = { "alternate": ($src+"/"+$file) }' > $TMPDIR/.projections.json.tmp
    mv $TMPDIR/.projections.json.tmp $project_name/.projections.json
done

function subst() {
    for arg in $@; do
        perl -spi -e 'BEGIN{use Env} s:<%\s*([^}]+)\s*%>:my $x = eval $1;$x=~s/^\s+|\s+$//g;$x:ge' -- $=xflags -- $arg
    done
}

if [[ -f $template_src/init.zsh ]]; then (
    cd $project_name
    eval "export xflags FORCE $(perl -e '$,=" ";for(@ARGV){s/^--?//;s/^[^=]+$/$&=1/;print}' -- $=xflags)"
    zsh -c "set -e; $(typeset -f subst); $(find "$template_src" -name init.zsh -exec cat {} +)"
); fi
