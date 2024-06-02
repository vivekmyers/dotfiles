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

pip install $@ || return 1

local args=( $( printf "%s\n" $@ | sed -E 's/[=<>].*//' ) )
local pat="$(IFS='|'; echo "${args[*]}")"
local added=( $(pip freeze | grep -E "($pat)=" | sort | uniq) )

for pkg in $added; do
    name="$(echo $pkg | sed -E 's/[=<>].*//')"
    version="$(echo $pkg | cut -d= -f3 | grep -oE '^[0-9.]*')"
    echo
    echo "Trying to add $name=$version to environment.yml"
    vim -Es \
        +"global/^-/normal I  " \
        +"/^dependencies:" +"+1" \
        +"while getline('.') =~ '^ *-' && getline('.') !~ '^ *- *pip:'
            | +1
        | endwhile" \
        +"if getline('.') !~ '.*pip:'
            | if getline('.') =~ '^ *$'
                | execute 'normal cc  - pip:'
            | else
                | execute 'normal o  - pip:'
            | endif
            | execute '!echo Added pip: to environment.yml:' . line('.')
            | +1
        | endif" \
        +"while getline('.') !~ '^ *- *$name' && getline('.') =~ '^ *-'
            | +1
        | endwhile" \
        +"if getline('.') =~ '^ *[^-].*:' && getline('.') !~ 'pip:'
            | -1
        | endif" \
        +"if getline('.') =~ '^ *- *$name'
            | let vers = matchstr(getline('.'), '=.*')
            | execute 'normal cc    - $name==$version'
            | execute '!echo Package $name==$version added to environment.yml:' . line('.') . ', replacing $name' . vers
        | else
            | if getline('.') =~ '^ *$' | execute 'normal cc    - $name==$version' | else | execute 'normal o    - $name==$version' | endif
            | execute '!echo Package $name==$version added to environment.yml:' . line('.')
        | endif" \
        +wq! environment.yml
    echo
done

echo "environment.yml updated:"
cat -n environment.yml
