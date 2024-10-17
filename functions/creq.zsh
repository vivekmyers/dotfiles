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

while [[ "$1" =~ ^- ]]; do
    shift
done

local args=( $( printf "%s\n" $@ | sed -E 's/[=<>].*//' ) )
local pat="$(IFS='|'; echo "${args[*]}")"
local added=( $(conda env export | grep -v 'pip:' | grep -E "^ *- *($pat)=" | sed 's/ *- *//' | sort | uniq) )

read -r -d '' script <<'EOF'
BEGIN                         { use Env; $level=0; $version=~s/([^.]*\.[^.]*(\.[^.]*)?).*/\1/ }
/^dependencies:/       and do { $level++ };
$level                 and do { s/^ *-/  -/; s/^ *- *$name.*$/  - $name=$version/ and do { $level = 0; } };
/^ *- *pip:/ && $level and do {  print "  - $name=$version"; $level = 0 };
eof && $level          and do { print; print "  - $name=$version"; exit }
EOF

for pkg in $added; do
    name="$(echo $pkg | sed -E 's/[=<>].*//')"
    version="$(echo $pkg | sed -E 's/=+/=/g' | cut -d= -f2 | grep -oE '^[0-9.]*')"
    echo "Trying to add $name=$version to environment.yml"

    name=$name version=$version perl -i -lpe "$script" environment.yml 
    echo
done

echo "environment.yml updated:"
cat -n environment.yml

