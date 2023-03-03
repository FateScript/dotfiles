
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
    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
    fi
}

updir()
{
    echo ${1%/*}
}

cdw()
{
    cd $(updir $(which $1))
}

cdfzf()
{
    cdw $(fzf)
}

env_get()
{
    local env_value
    env_value=$(env | grep "$1" | cut -d "=" -f2)
    if [[ -z "$env_value" ]]; then  # not exist
        env_value=$2
    fi
    echo "$env_value"
}

# Developement Settings {
# python venv fucntion
VENV_DIR="$HOME/workspace/env"

create_venv()
{
    python3 -m venv "$VENV_DIR"/"$1"
}

_act_venv()
{
    local state
	_arguments '1: :->list'
    case $state in
        list)
            _complete_venv
            ;;
    esac
}

_complete_venv(){
	choices=`ls_venv`
	suf=( -S '' )
	_arguments -O suf "*:value:( $choices )"
}

act_venv()
{
    source "$VENV_DIR"/"$1"/bin/activate
}

ls_venv()
{
    ls "$VENV_DIR"
}

# auto set venv
tmux_venv()
{
    tmux set-env VIRTUAL_ENV "$VIRTUAL_ENV"
}

# auto unset venv
tmux_rm_venv()
{
    tmux set-env -r VIRTUAL_ENV
}

# Since it will be set when enter zsh, this command is not in alias file.
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

_conf(){
	_arguments '1: :(xmonad tmux vim nvim zsh zshut zshal zshins)'
}

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


# Git related command
# list large file in git repo
# usage: $0 k
git_large_file()
{
    local k
    k=$1
    if [ -z "$1" ]; then
        k=5
    fi

    git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -$k | awk '{print$1}')"
}

# apply filter branch to remove history file
# usage: $0 filename
git_rm_history_file()
{
    if [ ! -z "$1" ]; then
        git filter-branch -f --prune-empty --index-filter 'git rm -rf --cached --ignore-unmatch $1' --tag-name-filter cat -- --all
    fi

}

git_ls_unreachable()
{
    git fsck --unreachable --no-reflog
}

git_gc_unreachable()
{
    git reflog expire --expire-unreachable="now" --all
    git prune --expire="now" -v
    git gc --aggressive --prune="now"
}

git_clean_branch()
{
    local origin=$1
    if [ -z "$1" ]; then
        origin=origin
    fi
    git remote prune $origin
    git branch --merged | egrep -v "(^\*|main)" | xargs git branch -d
}

# list disk usage. use -r to show descending order
duls()
{
    local val="$(du -sk * | sort -n $1 | sed -E ':a; s/([[:digit:]]+)([[:digit:]]{3})/\1,\2/; ta')"
    local val="$(echo $val | head -n 10)"
    local val="$(echo $val | awk -F'\t' '{printf "%10s %s\n",$1,substr($0,length($1)+2)}')"
    echo $val
}

# log related function
timelog()
{
    local now=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "\033[32m$now\033[0m" "$@"
}

warnlog()
{
    echo -e "\033[31m$@\033[0m"
}

show_cursor()
{
    echo -e "\033[?25h"
}

py_pack()
{
    timelog "packing whl now..."
    python3 setup.py sdist bdist_wheel
    timelog "pack whl into dist directory done..."
}
# }
