# some utilities

safe_source()
{
    [ -f  "$1" ] && source "$1"
}

export ZSH="$HOME/.oh-my-zsh"
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
)

[ "$OS_DISTRIBUTION" = 'ubuntu' ] && source /usr/share/autojump/autojump.sh

# enable gruvbox work in vimrc
export TERM=xterm-256color

# key bindings {
# default beginning-of-line is ctrl-a, which conflicted with keybinding ctrl-a
# used in tmux. 
bindkey '^D' beginning-of-line  # Bind Ctrl + D to beginning-of-line
bindkey '^F' forward-word  # Bind Ctrl + F to forward-word
bindkey '^B' backward-word  # Bind Ctrl + B to backward-word

# }

# alias and self defined function
safe_source $HOME/.zsh/utils.zsh
safe_source $ZSH/oh-my-zsh.sh

# ssh-agent {
#
# On Ubuntu, dbus will start ssh-agent

if [ "$OS_DISTRIBUTION" = "arch" ]; then
	if ! pgrep -u $USER ssh-agent > /dev/null; then
	    [ -d ~/.config ] || mkdir -v ~/.config
	    ssh-agent > ~/.config/ssh-agent-thing
	    echo "ssh-agent started"
	fi
	eval $(<~/.config/ssh-agent-thing) > /dev/null
fi

# }

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f ~/.zsh_additional ] && source ~/.zsh_additional

# Activate virtual env and save the path as a tmux variable,
# so that new panes/windows can re-activate as necessary
if [ -n "$VIRTUAL_ENV" ]; then
    source $VIRTUAL_ENV/bin/activate;
fi
