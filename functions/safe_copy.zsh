if [[ $# -lt 2 ]]; then
  echo "Usage: safe_copy <src> <src> ... <dst>"
  return 1
fi

local src=(${@:1:-1})
local dst="${@:$(($#))}"

for file in $src; do
  if [[ -e $file ]]; then
    local base=$(basename $file)
    cp -i $file $dst/$base
  else
    echo "File not found: $file"
  fi
done
