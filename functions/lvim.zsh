trap 'rm -f $tempfile' EXIT
tempfile=$TMPDIR/$RANDOM.pipe

( cat > $tempfile & )

if [[ -z "$1" ]]; then
    vim "$tempfile"
else
    vim +"set ft=$1" "$tempfile"
fi

cat $tempfile


