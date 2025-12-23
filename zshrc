# some utilities

function safe_source() { [ -f  "$1" ] && source "$1" }
# function safe_export_path() { [[ -d $1 ]] && export PATH=$1:$PATH }
function safe_add_fpath() { [[ -d "$1" ]] && fpath=("$1" $fpath) }  # NOTE: don't quote fpath here
function safe_export_path() {
    if [[ -d "$1" ]]; then
        if [[ ":$PATH:" == *":$1:"* ]]; then
            echo "$1 already exists in PATH"
        else
            export PATH="$1:$PATH"
        fi
    fi
}

# export zsh is important
export ZSH="$HOME/.oh-my-zsh"
export FZF_DEFAULT_OPTS='--bind ctrl-d:page-down,ctrl-u:page-up'  # like vim
export PYTHONBREAKPOINT="ipdb.set_trace"
# enable gruvbox work in vimrc
export TERM=xterm-256color

setopt complete_aliases  # enable alias completion

# zsh history settings
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=100000
export SAVEHIST=80000
setopt INC_APPEND_HISTORY    # append history as soon as the command is executed
setopt HIST_IGNORE_DUPS      # don't record an entry that was just recorded again
setopt HIST_IGNORE_SPACE     # don't save commands that start with a space
setopt HIST_FIND_NO_DUPS     # don't display duplicates in history search
setopt HIST_NO_FUNCTIONS     # don't save function definitions in the history file
setopt SHARE_HISTORY         # share history between all sessions
unsetopt EXTENDED_HISTORY    # disable the extended history format that includes timestamp information for each command

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="candy"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    uv
    autojump
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf-tab
    docker
    docker-compose
)

# alias and self defined function
safe_export_path $HOME/.local/bin >/dev/null
safe_source $ZSH/oh-my-zsh.sh
safe_source $HOME/.zsh/base.zsh

for file in $HOME/.zsh/*.zsh; do
    source $file
done

safe_add_fpath "$HOME/.zsh/Completion"
safe_add_fpath "$HOME/.zsh/functions"

safe_source "$HOME"/.fzf.zsh
safe_source "$HOME"/.zsh.local  # local file is used to store local configuration
safe_source "$HOME"/.zsh/utils.zsh

# Activate virtual env and save the path as a tmux variable,
# so that new panes/windows can re-activate as necessary
[[ -n "$VIRTUAL_ENV" ]] && source $VIRTUAL_ENV/bin/activate
[[ -s $HOME/.python_startup.py ]] && export PYTHONSTARTUP=$HOME/.python_startup.py
