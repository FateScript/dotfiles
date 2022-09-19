# some utilities
source $HOME/.zsh/utils.zsh
source $HOME/.zsh/install.zsh

# antigen plugins {
source $HOME/.zsh/antigen.zsh
antigen use oh-my-zsh

antigen bundle git
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions

antigen bundle autojump
[ $OS_DISTRIBUTION = 'ubuntu' ] && source /usr/share/autojump/autojump.sh

antigen theme candy

antigen apply
# }

# enable gruvbox work in vimrc
export TERM=xterm-256color

# key bindings {

# default beginning-of-line is ctrl-a, which conflicted with keybinding ctrl-a
# used in tmux. 
bindkey '^D' beginning-of-line  # ctrl-d 

# }

# alias
source $HOME/.zsh/alias.zsh

# ssh-agent {
#
# On Ubuntu, dbus will start ssh-agent

if [ $OS_DISTRIBUTION = 'arch' ]; then
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
