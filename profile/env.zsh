export PATH="$HOME/.local/bin:$PATH"
export PATH="$CONDA_PREFIX/bin:$PATH"
export PATH="$HOME/google-cloud-sdk/bin:$PATH"

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$( ( IFS=: && x=( $HOME/.mujoco/*/bin ) && echo "${x[*]}") 2>/dev/null)

export TERM="xterm-256color"
export EDITOR="vim"
# export OPENAI_API_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
export SQUEUE_FORMAT2="JobID:.8 ,Name:.70 ,QOS:.15 ,UserName:.8 ,StateCompact:.2 ,TimeUsed:.12 ,NodeList:.20 ,Tres:.50 ,Reason"

export AUTOSSH_PORT=2022

export VIMSESSION=.session.vim

if [ -n "$ZSH_VERSION" ]; then
    unsetopt nomatch
fi

export AUTOSWITCH_DEFAULT_CONDAENV=base

autoload -Uz bashcompinit && bashcompinit
export LANG=en_US.UTF-8
export DEFAULT_USER=vivek

