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

while [[ "$1" =~ ^- ]]; do
    shift
done

local args=( $( printf "%s\n" $@ | sed -E 's/[=<>].*//' ) )
local pat="$(IFS='|'; echo "${args[*]}")"
local added=( $(pip freeze | grep -E "($pat)=" | sort | uniq) )

read -r -d '' script <<'EOF'
BEGIN                             { use Env; $level=0; $found=0; }
/^ *-.*:$/                        and do { $level=0 };
/^ *-.*:$/ && !$found && $level   and do { print "    - $name==$version"; $found=1 };
/^ *- *pip:/                      and do { $level=1; next };
$level                            and do { 
                                      s/^ *-/    -/; s/^ *- *$name.*$/    - $name==$version/ and do { 
                                          $level = 0;
                                          $found=1;
                                      }
                                  };
!$found && $level 
    && /^\s*[^- ]|^\s*$/          and do { print "    - $name==$version"; $found=1; $level=0; next; };
eof && !$found                    and do { print; print "  - pip:" if !$level; print "    - $name==$version"; exit };
EOF

for pkg in $added; do
    name="$(echo $pkg | sed -E 's/[=<>].*//')"
    version="$(echo $pkg | cut -d= -f3 | grep -oE '^[0-9.]*(\+([a-z0-9]+\.?)*)?$')"
    echo
    echo "Trying to add $name=$version to environment.yml"
    name=$name version=$version perl -i -lpe "$script" environment.yml 
    echo
done

echo "environment.yml updated:"
cat -n environment.yml
