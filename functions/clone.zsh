name=$1
shift

git clone --recursive git@github.com:vivekmyers/$name $@
