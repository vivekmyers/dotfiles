if [[ ! -f "environment.yml" ]]; then
    echo "environment.yml not found in the current directory"
    return 1
fi

local ENVNAME=$(awk '/name:/ {print $2}' environment.yml)

if [[ "$CONDA_DEFAULT_ENV" != $ENVNAME ]]; then
    conda activate $ENVNAME || {
        (cact && local ENVNAME="$CONDA_DEFAULT_ENV") || return 1
    }
fi

conda install -y $@ || return 1

local args=( $( printf "%s\n" $@ | sed -E 's/[=<>].*//' ) )
local pat="$(IFS='|'; echo "${args[*]}")"
local added=( $(conda env export | grep -v 'pip:' | grep -E "^ *- *($pat)=" | sed 's/ *- *//' | sort | uniq) )

for pkg in $added; do
    name="$(echo $pkg | sed -E 's/[=<>].*//')"
    version="$(echo $pkg | sed -E 's/=+/=/g' | cut -d= -f2 | grep -oE '^[0-9.]*')"
    echo "Trying to add $name=$version to environment.yml"
    vim -Es \
        +"global/^-/normal I  " \
        +"/^dependencies:" \
        +"+1" \
        +"while getline('.') !~ '^ *- *$name' && getline('.') =~ '^ *-' && getline('.') !~ '^ *- *pip:'
            | +1 
        | endwhile" \
        +"if getline('.') =~ '.*:' || getline('.') =~ '^ *$' 
            | -1
        | endif" \
        +"if getline('.') =~ '^ *- *$name' 
            | let vers = matchstr(getline('.'), '=.*')
            | execute 'normal cc  - $name=$version'
            | execute '!echo Package $name=$version added to environment.yml:' . line('.') . ', replacing $name' . vers
        | else 
            | execute 'normal o- $name=$version'
            | execute '!echo Package $name=$version added to environment.yml:' . line('.')
        | endif" \
        +wq! environment.yml
    echo
done

echo "environment.yml updated:"
cat -n environment.yml

