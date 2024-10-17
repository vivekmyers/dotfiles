load utils

function commit_config {
    (
        find $CONFIGDIR -type f -name ".session.vim" -delete -print | xargs -I{} echo "Deleted: {}"
        find $CONFIGDIR -type f -name "*.sw[klmnop]" -delete -print | xargs -I{} echo "Deleted: {}"
        find $CONFIGDIR -name .DS_Store -delete -print | xargs -I{} echo "Deleted: {}" 
        find $CONFIGDIR -name .git | while read line; do
        zsh -c "load utils; cd "$(dirname $line)" && git add . && mcom"
        done 
    ) 
    zsh -c 'cd $CONFIGDIR && git pull && git push'
    zsh -c 'cd $CONFIGDIR && make'
}

commit_config "$@"
