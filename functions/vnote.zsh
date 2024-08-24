trap 'rm -f $tempfile' EXIT
tempfile=$TMPDIR/$RANDOM.py

vim +'set bt=nowrite' +'call python#notebooksetup()' +'call jukit#splits#output_and_history()' +'startinsert'  "$tempfile"



