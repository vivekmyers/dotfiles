if [[ ! -e "$VIMSESSION" ]]; then
    vim +MRU +'norm! o'
else
    vim -S $VIMSESSION
fi
