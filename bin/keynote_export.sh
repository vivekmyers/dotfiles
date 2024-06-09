#!/usr/bin/env bash
PACKAGE=$(basename $0)
VERSION="0.0.0.9001"

absolute_path () {
  if [[ "$1" = /* ]]; then
    echo ${1%/}
  else
    echo $(pwd)/${1%/}
  fi
}

echo_help () {
  echo "$PACKAGE - Export Keynote file to PDF/JPEG"
  echo " "
  echo "$PACKAGE [options] keynote_dir"
  echo "options:"
  echo "-h, --help                show brief help"
  echo "-o, --output-dir=DIR      Output directory."
  echo "-t, --type                pdf or jpeg"
}

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo_help
      exit 0;;
    -o|--output-dir*)
      shift
      OUTPUTDIR=$(absolute_path $1)
      shift;;
    -t|--type*)
      shift
      TYPE=$1
      shift;;
    *)
      if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
        param+=( "$1" )
      fi
      shift;;
  esac
done

INPUTDIR=$(absolute_path ${param[0]})
if [[ -z "$INPUTDIR" ]]; then
  echo "Input directory is not specified."
  exit 1
fi

[[ -z "$OUTPUTDIR" ]] && OUTPUTDIR="$INPUTDIR"
[[ -z "$TYPE" ]] && TYPE="pdf"

# The main loop
# Call an applescript to do the conversion.
for keyfile in $INPUTDIR/*.key; do
  BASE=$(basename "$keyfile")
  OUTFILE=$OUTPUTDIR/${BASE%.*}.$TYPE
  osascript keynote_export.applescript "$keyfile" "$OUTFILE"
done

exit 0
