load conda_hook
alias conda=mamba

if ! type conda > /dev/null; then
    export DISABLE_AUTOSWITCH_CENV="1"
    printf "\e[1m\e[31m"
    printf "zsh-autoswitch-conda requires conda to be installed!\n\n"
    printf "\e[0m\e[39m"
    printf "If this is already installed but you are still seeing this message, \nadd the "
    printf "following to your ~/.zshenv:\n\n"
    printf "\e[1m"
    printf ". YOUR_CONDA_PATH/etc/profile.d/conda.sh\n"
    printf "\n"
    printf "\e[0m"
    printf "https://github.com/bckim92/zsh-autoswitch-conda#Setup"
    printf "\e[0m"
    printf "\n"
fi


function _maybeactivate() {
  if [[ -z "$CONDA_DEFAULT_ENV" || "$1" != "$(basename $CONDA_DEFAULT_ENV)" ]]; then
     if [ -z "$AUTOSWITCH_SILENT" ]; then
        printf "Switching conda environment: %s  " $1
     fi

     conda activate "$1"

     if [ -z "$AUTOSWITCH_SILENT" ]; then
       # For some reason python --version writes to st derr
       printf "[%s]\n" "$(python --version 2>&1)"
     fi
  fi
}


# Gives the path to the nearest parent .cenv file or nothing if it gets to root
function _check_cenv_path()
{
    local check_dir=$1

    if [[ -f "${check_dir}/.cenv" ]]; then
        printf "${check_dir}/.cenv"
        return
    else
        if [ "$check_dir" = "/" ]; then
            return
        fi
        _check_cenv_path "$(dirname "$check_dir")"
    fi
}


# Automatically switch conda environment when .cenv file detected
function check_cenv()
{
    if [ "AS_CENV:$PWD" != "$MYOLDPWD" ]; then
        # Prefix PWD with "AS_CENV:" to signify this belongs to this plugin
        # this prevents the AUTONAMEDIRS in prezto from doing strange things
        # (Since zsh-autoswitch-virtualenv use "AS:" prefix, we instead use "AS_CENV:"
        # See https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv/issues/19
        MYOLDPWD="AS_CENV:$PWD"

        SWITCH_TO=""

        # Get the .cenv file, scanning parent directories
        cenv_path=$(_check_cenv_path "$PWD")
        if [[ -n "$cenv_path" ]]; then

          stat --version &> /dev/null
          if [[ $? -eq 0 ]]; then   # Linux, or GNU stat
            file_owner="$(stat -c %u "$cenv_path")"
            file_permissions="$(stat -c %a "$cenv_path")"
          else                      # macOS, or FreeBSD stat
            file_owner="$(stat -f %u "$cenv_path")"
            file_permissions="$(stat -f %OLp "$cenv_path")"
          fi

          if [[ "$file_owner" != "$(id -u)" ]]; then
            printf "AUTOSWITCH WARNING: Conda environment will not be activated\n\n"
            printf "Reason: Found a .cenv file but it is not owned by the current user\n"
            printf "Change ownership of $cenv_path to '$USER' to fix this\n"
          elif [[ "$file_permissions" != "600" ]]; then
            printf "AUTOSWITCH WARNING: Conda environment will not be activated\n\n"
            printf "Reason: Found a .cenv file with weak permission settings ($file_permissions).\n"
            printf "Run the following command to fix this: \"chmod 600 $cenv_path\"\n"
          else
            SWITCH_TO="$(<"$cenv_path")"
          fi
        fi

        if [[ -n "$SWITCH_TO" ]]; then
          _maybeactivate "$SWITCH_TO"
        else
          _default_cenv
        fi
    fi
}

# Switch to the default conda environment
function _default_cenv()
{
  if [[ -n "$AUTOSWITCH_DEFAULT_CONDAENV" ]]; then
     _maybeactivate "$AUTOSWITCH_DEFAULT_CONDAENV"
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
     conda deactivate
  fi
}

# remove conda environment for current directory
function rmcenv()
{
  if [[ -f ".cenv" ]]; then

    cenv_name="$(<.cenv)"

    # detect if we need to switch conda environment first
    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        current_cenv="$(basename $CONDA_DEFAULT_ENV)"
        if [[ "$current_cenv" = "$cenv_name" ]]; then
            _default_cenv
        fi
    fi

    conda env remove --name "$cenv_name"
    rm ".cenv"
  else
    printf "No .cenv file in the current directory!\n"
  fi
}


function ndcenv {
    PIP_NO_DEPS=1 fcenv "$@"
}

# helper function to create a conda environment for the current directory
function mkcenv()
{
  if [[ -f ".cenv" ]]; then
    printf ".cenv file already exists. If this is a mistake use the rmcenv command\n"
  else
    cenv_name="$(basename $PWD)"
    conda create --name "$cenv_name" $@
    conda activate "$cenv_name"

    if [[ -f "environment.yml" ]]; then
        printf "Found an environment.yml file. Installing using conda...\n"
        conda env update --name "$cenv_name" --file environment.yml
    fi

    printf "$cenv_name\n" > ".cenv"
    chmod 600 .cenv
    AUTOSWITCH_PROJECT="$PWD"
  fi
}

function cinit {
    cenv_name="$(basename $PWD)"
    printf "$cenv_name\n" > ".cenv"
    chmod 600 .cenv
    AUTOSWITCH_PROJECT="$PWD"
    cact
}

function cbase {
    cenv_name="$(<.cenv)"
    conda env update --name $cenv_name --file ~/.local/etc/environment.yml
}

function cact {
    if [[ -f ".cenv" ]]; then
        cenv_name="$(<.cenv)"
        conda activate "$cenv_name"
    else
        printf "No .cenv file in the current directory!\n"
    fi
}

function cconf {
    local file="$CONDA_PREFIX/etc/conda/activate.d/$1.sh"
    local src
    mkdir -p "$(dirname "$file")"
    if [[ -f "$file" ]]; then
        src="$(readlink -f $file)"
    else
        src="$PWD/.$1"
    fi
    touch "$src"
    ln -sf "$src" "$file"
    $EDITOR "$src"
    source "$src"
    echo "New conda configuration file $src linked to $file"
}

function cclear {
     for file in $CONDA_PREFIX/etc/conda/activate.d/*; do
         local linked="$(readlink -f "$file")" &&
         test -L "$file" &&
         rm -f "$file" &&
         echo "Removed conda configuration file $file linked to $linked"
     done
}

function rmcconf {
    local file="$CONDA_PREFIX/etc/conda/activate.d/$1.sh"
    rm -f "$file"
    echo "Removed conda configuration file $file"
}

function fcenv {
    local cenv_name
    if [[ -f ".cenv" ]]; then
        cenv_name="$(<.cenv)"

        # detect if we need to switch conda environment first
        if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
            current_cenv="$(basename $CONDA_DEFAULT_ENV)"
            if [[ "$current_cenv" = "$cenv_name" ]]; then
                _default_cenv
            fi
        fi

        if [[ -n "$cenv_name" ]]; then
            conda remove --name "$cenv_name" --yes --all &&
            rm ".cenv" 
        fi
    fi
    cenv_name="$(basename $PWD)" &&
    yes | conda create --name "$cenv_name" $@ &&
    conda activate "$cenv_name" &&
    cinst env &&

    if [[ -f "environment.yml" ]]; then
      printf "Found an environment.yml file. Installing using conda...\n"
      conda env update --name "$cenv_name" --file environment.yml || return
    fi

    printf "$cenv_name\n" > ".cenv" &&
    chmod 600 .cenv
    AUTOSWITCH_PROJECT="$PWD"
}

function ecenv {
    local cenv_name
    if [[ -f ".cenv" ]]; then
        cenv_name="$(<.cenv)"

        # detect if we need to switch conda environment first
        if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
            current_cenv="$(basename $CONDA_DEFAULT_ENV)"
            if [[ "$current_cenv" = "$cenv_name" ]]; then
                _default_cenv
            fi
        fi

        if [[ -n "$cenv_name" ]]; then
            conda remove --name "$cenv_name" --yes --all &&
            rm ".cenv" 
        fi
    fi
    cenv_name="$(basename $PWD)" &&
    yes | conda create --name "$cenv_name" --yes --clone base &&
    cinst env &&
    conda activate "$cenv_name" &&

    if [[ -f "environment.yml" ]]; then
      printf "Found an environment.yml file. Installing using conda...\n"
      conda env update --name "$cenv_name" --file environment.yml --prune || return
    fi

    printf "$cenv_name\n" > ".cenv" &&
    chmod 600 .cenv
    AUTOSWITCH_PROJECT="$PWD"
}

function _cinst {
	local file="$CONDA_PREFIX/etc/conda/activate.d/$1.sh"
	local src
	mkdir -p "$(dirname "$file")"
	if [[ -f "$file" ]]
	then
		src="$(readlink -f $file)"
	else
		src="$PWD/.$1"
	fi
	touch "$src"
	ln -sf "$src" "$file"
	source "$src"
	echo "New conda configuration file $src linked to $file"
}

function cinst {
    rep _cinst "$@"
}


if [[ -z "$DISABLE_AUTOSWITCH_CENV" ]]; then
    autoload -Uz add-zsh-hook
    add-zsh-hook -D chpwd check_cenv
    add-zsh-hook chpwd check_cenv
fi

