
get_os_distribution() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }'
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        echo "ID=macos" | awk -F'=' '{ print tolower($2) }'
    fi
}

OS_DISTRIBUTION=$(get_os_distribution)

# Developement Settings {
act_venv() {
    source ~/workspace/env/$1/bin/activate
}

# auto set venv
tmux_venv() {
    tmux set-env VIRTUAL_ENV $VIRTUAL_ENV
}

# auto unset venv
tmux_rm_venv() {
    tmux set-env -r VIRTUAL_ENV
}

# configuration shortcut {
conf() {
	case $1 in
		xmonad)		vim ~/.xmonad/xmonad.hs ;;
		tmux)		vim ~/.tmux.conf ;;
		vim)		vim ~/.vimrc ;;
		nvim)		vim ~/.config/nvim/init.vim ;;
		zsh)		vim ~/.zshrc ;;
		zshut)      vim ~/.zsh/utils.zsh ;;
		zshal)      vim ~/.zsh/alias.zsh ;;
		*)		echo "Unknown application $1" ;;
	esac
}
# }

# search the content and open the file
agopen() {
    local file_lino="$(ag --filename $1 | fzf | awk -F '[:]' '{print $1, $2}')"
    if [ ! -z "$file_lino" ]; then
        local file="$(echo "$file_lino" | awk -F '[  ]' '{print $1}')"
        local lino="$(echo "$file_lino" | awk -F '[  ]' '{print $2}')"
        echo -e "+$lino $file" | xargs -o vim
    fi
}

# list disk usage. use -r to show descending order
duls() {
    local val="$(du -sk * | sort -n $1 | sed -E ':a; s/([[:digit:]]+)([[:digit:]]{3})/\1,\2/; ta')"
    local val="$(echo $val | head -n 10)"
    local val="$(echo $val | awk -F'\t' '{printf "%10s %s\n",$1,substr($0,length($1)+2)}')"
    echo $val
}
# }
