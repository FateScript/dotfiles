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


export ZSH="$HOME/.oh-my-zsh"
export FZF_DEFAULT_OPTS='--bind ctrl-d:page-down,ctrl-u:page-up'  # like vim
export PYTHONBREAKPOINT="ipdb.set_trace"
# enable gruvbox work in vimrc
export TERM=xterm-256color

setopt complete_aliases  # enable alias completion

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
    autojump
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf-tab
    docker
    docker-compose
)

# to workaround docker.plugin.zsh settings
cp $ZSH/plugins/docker/completions/_docker $ZSH_CACHE_DIR/completions/_docker

# alias and self defined function
safe_export_path $HOME/.local/bin >/dev/null
safe_source $ZSH/oh-my-zsh.sh
for file in $HOME/.zsh/*.zsh; do
    source $file
done

safe_add_fpath "$HOME/.zsh/Completion"
safe_add_fpath "$HOME/.zsh/functions"

# ssh-agent {
#
# On Ubuntu, dbus will start ssh-agent

if [ "$OS_DISTRIBUTION" = "arch" ]; then
	if ! pgrep -u $USER ssh-agent > /dev/null; then
	    [ -d "$HOME"/.config ] || mkdir -v "$HOME"/.config
	    ssh-agent > ~/.config/ssh-agent-thing
	    echo "ssh-agent started"
	fi
	eval $(<~/.config/ssh-agent-thing) > /dev/null
fi

# }

safe_source "$HOME"/.fzf.zsh
safe_source "$HOME"/.zsh.local  # local file is used to store local configuration

# Activate virtual env and save the path as a tmux variable,
# so that new panes/windows can re-activate as necessary
if [ -n "$VIRTUAL_ENV" ]; then
    source $VIRTUAL_ENV/bin/activate;
fi
