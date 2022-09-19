
get_os_distribution()
{
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }'
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        echo "ID=macos" | awk -F'=' '{ print tolower($2) }'
    fi
}

OS_DISTRIBUTION=$(get_os_distribution)

ensure_dir()
{
    if [[ ! -d $1 ]]; then
        mkdir -p $1
    fi
}

env_get()
{
    local env_value
    env_value=$(env | grep $1 | cut -d "=" -f2)
    if [[ -z $env_value ]]; then  # not exist
        env_value=$2
    fi
    echo $env_value
}

# Developement Settings {
# python venv fucntion
VENV_DIR="$HOME/workspace/env"

create_venv()
{
    local venv_name
    venv_name=$1
    python3 -m venv $VENV_DIR/$venv_name
}

act_venv()
{
    source $VENV_DIR/bin/activate
}

ls_venv()
{
    ls $VENV_DIR
}

# auto set venv
tmux_venv()
{
    tmux set-env VIRTUAL_ENV $VIRTUAL_ENV
}

# auto unset venv
tmux_rm_venv()
{
    tmux set-env -r VIRTUAL_ENV
}

vf()
{
    vim $(fzf)
}
# use ag to search the content and open the file
agopen()
{
    local file_lino="$(ag --filename $1 | fzf | awk -F '[:]' '{print $1, $2}')"
    if [ ! -z "$file_lino" ]; then
        local file="$(echo "$file_lino" | awk -F '[  ]' '{print $1}')"
        local lino="$(echo "$file_lino" | awk -F '[  ]' '{print $2}')"
        echo -e "+$lino $file" | xargs -o vim
    fi
}

rgopen()
{
    local file_lino="$(rg $1 -n | fzf | awk -F '[:]' '{print $1, $2}')"
    if [ ! -z "$file_lino" ]; then
        local file="$(echo "$file_lino" | awk -F '[  ]' '{print $1}')"
        local lino="$(echo "$file_lino" | awk -F '[  ]' '{print $2}')"
        echo -e "+$lino $file" | xargs -o vim
    fi
}

# configuration shortcut {
conf()
{
	case $1 in
		xmonad)		vim ~/.xmonad/xmonad.hs ;;
		tmux)		vim ~/.tmux.conf ;;
		vim)		vim ~/.vimrc ;;
		nvim)		vim ~/.config/nvim/init.vim ;;
		zsh)		vim ~/.zshrc ;;
		zshut)      vim ~/.zsh/utils.zsh ;;
		zshal)      vim ~/.zsh/alias.zsh ;;
		zshins)     vim ~/.zsh/install.zsh ;;
		*)		echo "Unknown application $1" ;;
	esac
}
# }

# list disk usage. use -r to show descending order
duls()
{
    local val="$(du -sk * | sort -n $1 | sed -E ':a; s/([[:digit:]]+)([[:digit:]]{3})/\1,\2/; ta')"
    local val="$(echo $val | head -n 10)"
    local val="$(echo $val | awk -F'\t' '{printf "%10s %s\n",$1,substr($0,length($1)+2)}')"
    echo $val
}

timelog()
{
    local now=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "\033[32m$now\033[0m" "$@"
}

warnlog()
{
    echo -e "\033[31m$@\033[0m"
}

# }
