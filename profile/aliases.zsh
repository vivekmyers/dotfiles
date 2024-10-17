alias ls='ls --color'
alias grep='grep --color'
alias less='less -r'
alias more='more -r'
export LSCOLORS=GxFxCxDxBxegedabagaced

alias list='printf "%s\n"'
alias lsao='ls -lahO@e'
alias topu="top -u"
alias xcode='open -a Xcode'
alias ovim="vim +'norm!"'`0'"'"

if command -v with-readline > /dev/null; then
    alias rlwrap=with-readline
    alias sftp='rlwrap sftp'
fi

alias apps='cd /Applications'
alias docs='cd ~/Documents'
alias res='cd ~/Documents/Research'
alias desk='cd ~/Desktop'
alias bin='cd /usr/local/bin'
alias less="less -r"
alias template="nocorrect template"

alias gvim="vim +'G' +'norm!o'"
alias otp='sshpass -p $(google_auth.py)'
alias ladog='git log --all --decorate --oneline --graph'

alias monero=monero-wallet-cli

bindkey -s "^Q" '^Acd ^M'
bindkey -s "^V" '^Usvim^M'

