# some utilities
source $HOME/.zsh/utils.zsh

# antigen plugins {
source $HOME/.zsh/antigen.zsh
antigen use oh-my-zsh

antigen bundle git
antigen bundle zsh-users/zsh-syntax-highlighting

antigen bundle autojump
[ $OS_DISTRIBUTION = 'ubuntu' ] && source /usr/share/autojump/autojump.sh

antigen theme candy

antigen apply
# }


# aliases {
alias -g L='| less'
alias -g JL='| jq | less'
alias -g CL='| pygmentize | less'
alias -g G='| grep'

alias m='make'

alias sv='sudo vim'
alias vi='vim'
alias v=vim
alias c='cat'

alias ipy="python -c 'import IPython; IPython.terminal.ipapp.launch_new_instance()'"

alias rf='readlink -f'

alias findname='find . -name'

# kill process with python, run `pshow python KILL`
alias pshow="ps -ef | grep"
alias -g KILL="| awk '{print \$2}' | head -n -1 | xargs kill -9"

# diff dir a and b, run `diffdir a b DIFF`
alias diffdir="diff --exclude '*.txt' --exclude '*.pkl' --exclude '*__pycache__*'"
alias -g DIFF="--width=$COLUMNS --suppress-common-lines --side-by-side --recursive"

# tar aliases
alias tarinfo="tar -tf"
alias tarzip="tar -zcvf"
alias tarunzip="tar -zxvf"

# git aliases
alias gs='git status'
alias ga='git add'
alias gm='git commit -m'
alias gd='git diff'
alias grm='git rm'
alias gmv='git mv'
alias gck='git checkout'
alias gr="git remote"
alias gdown='git reset HEAD'
alias gremove='git checkout --'


if [ $OS_DISTRIBUTION = 'arch' ]; then
	alias yS='yaourt -S --noconfirm --needed'
	alias ySs='yaourt -Ss'
	alias pS='sudo pacman -S --noconfirm --needed'
	alias pSs='sudo pacman -Ss'
fi

# }

# key bindings {

# default beginning-of-line is ctrl-a, which conflicted with keybinding ctrl-a
# used in tmux. 
bindkey '^D' beginning-of-line  # ctrl-d 

# }


# Developement Settings {

# configuration shortcut {
conf() {
	case $1 in 
		xmonad)		vim ~/.xmonad/xmonad.hs ;;
		tmux)		vim ~/.tmux.conf ;;
		vim)		vim ~/.config/nvim/init.vim ;;
		nvim)		vim ~/.vimrc ;;
		zsh)		vim ~/.zshrc ;;
		*)		echo "Unknown application $1" ;;
	esac
}
# }

# enable gruvbox work in vimrc
export TERM=xterm-256color

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
