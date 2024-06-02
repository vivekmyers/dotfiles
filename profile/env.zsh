export path=(
    $(printf "%s\n" $path | grep conda || echo $HOME/conda/*bin)
    $HOME/.local/bin
    $HOME/bin
    $HOME/google-cloud-sdk/bin
    $HOME/.mujoco/*/bin
    /usr/local/bin
    $(printf "%s\n" $path | sed 1d | grep -v "$HOME")
)

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$( ( IFS=: && x=( $HOME/.mujoco/*/bin ) && echo "${x[*]}") 2>/dev/null)

# export TERM="xterm-256color"
export EDITOR="vim"
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

# if command -v nvidia-smi &> /dev/null; then
#     export CUDA_VISIBLE_DEVICES="$(nvidia-smi | awk -F ' ' '$3=="NVIDIA"{i=$2;n=NR} NR==n+1&&n{print $9,i | "sort | head -n1 | cut -d\\  -f2" }')"
# fi

