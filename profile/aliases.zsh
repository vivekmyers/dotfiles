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

alias apps='cd /Applications'
alias docs='cd ~/Documents'
alias res='cd ~/Documents/Research'
alias desk='cd ~/Desktop'
alias bin='cd /usr/local/bin'
alias less="less -r"

alias gvim="test -e .git && vim +'G' +'norm!o'"
alias otp='sshpass -p $(google_auth.py)'

alias monero=monero-wallet-cli

bindkey -s "^Q" '^Acd ^M'
bindkey -s "^V" '^Uvim^M'
bindkey -s "^[" '^Ucd -^M'
