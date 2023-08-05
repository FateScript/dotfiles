
get_os_distribution()
{
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }'
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        echo "ID=macos" | awk -F'=' '{ print tolower($2) }'
    fi
}

get_os_version() {
    if [[ "$(uname)" == "Darwin" ]]; then  # macOS
        sw_vers -productVersion
    elif [[ "$(uname)" == "Linux" ]]; then  # Linux
        if command -v lsb_release >/dev/null 2>&1; then
            lsb_release -r -s
        else
            echo "lsb_release command not found. Unable to determine the OS version."
        fi
    else
        echo "Unsupported operating system: $(uname). Unable to determine the OS version."
    fi
}

OS_DISTRIBUTION=$(get_os_distribution)
OS_VERSION=$(get_os_version)
PATH_CKPT="$HOME"

safe_source()
{
    [ -f  "$1" ] && source "$1"
}

timelog()
{
    # log related function with timestamp
    local now=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "\033[32m$now\033[0m" "$@"
}

warnlog()
{
    echo -e "\033[31m$@\033[0m"
}

ensure_dir()
{
    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
    fi
}

join_paths() {
    local -a paths
    paths=("${(s:/:)1}")
    paths+=("${(@)@[2,-1]}")
    local joined_path="${(j:/:)paths}"
    echo "$joined_path"
}

updir()
{
    if [[ -z "$1" ]]; then
        echo $(dirname $PWD)
    else
        echo ${1%/*}
    fi
}

cdw()
{
    cd $(updir $(which $1))
}

cdfzf()
{
    local file=$(fzf)
    if [[ -z "$file" ]]; then
        return
    fi
    cd $(updir $(realpath $file))
}

swap_file()
{
    # Check if two arguments are provided
    if [ $# -ne 2 ]; then
        echo "Usage: swap_file file1 file2"
        return 1
    fi

    local file1="$1"
    local file2="$2"

    # Check if both files exist
    if [ ! -f "$file1" ] || [ ! -f "$file2" ]; then
        echo "Error: Both files must exist."
        return 1
    fi

    # Generate a temporary filename
    local tempfile=".swap_temp_file"

    # Perform the swap using mv command
    mv "$file1" "$tempfile"
    mv "$file2" "$file1"
    mv "$tempfile" "$file2"

    echo "Swapped filenames successfully!"
}

src() {
    # Function to display the source code of a given function/alias
    local func_name="$1"
    if [[ -z "$func_name" ]]; then
        echo "Usage: src <function_name>"
        return 1
    fi

    local func_code
    func_code=$(functions "$func_name")

    if [[ -z "$func_code" ]]; then
        (( $+aliases[$func_name] )) && echo $aliases[$func_name]
        return
    fi

    func_code=$(echo "$func_code" | expand -t 4)
    echo "$func_code"
}

mvp() {
    # Function to rename only the prefix of a file
    # example usage: mvp /path/a.txt b
    local old_prefix new_prefix extension old_file new_file

    old_prefix="$1"
    new_prefix="$2"

    # Check if old_prefix exists and is a file
    if [[ ! -f "$old_prefix" ]]; then
        echo "Error: $old_prefix does not exist or is not a file."
        return 1
    fi

    # Extract the extension from the old prefix (if any)
    extension=${old_prefix##*.}

    # Get the full path of the old file
    old_file=$(realpath "$old_prefix")

    # Create the new file name with the new prefix and the same extension
    new_file="$(dirname "$old_file")/$new_prefix.${extension:-""}"

    # Check if the new file name already exists
    if [[ -e "$new_file" ]]; then
        echo "Error: $new_file already exists."
        return 1
    fi

    # Rename the file
    mv "$old_file" "$new_file"

    echo "Renamed $old_file to $new_file."
}

mvs() {
    # Function to rename only the suffix of a file
    # Example usage: mvs /path/a.txt .pdf
    local old_suffix new_suffix old_file new_file

    old_suffix="$1"
    new_suffix="$2"

    # Check if old_suffix exists and is a file
    if [[ ! -f "$old_suffix" ]]; then
        echo "Error: $old_suffix does not exist or is not a file."
        return 1
    fi

    # Get the full path of the old file
    old_file=$(realpath "$old_suffix")

    # Extract the file name without extension
    filename=$(basename -- "$old_file")
    filename_without_extension=${filename%.*}

    # Create the new file name with the same prefix and the new suffix
    new_file="$(dirname "$old_file")/${filename_without_extension}$new_suffix"

    # Check if the new file name already exists
    if [[ -e "$new_file" ]]; then
        echo "Error: $new_file already exists."
        return 1
    fi

    # Rename the file
    mv "$old_file" "$new_file"

    echo "Renamed $old_file to $new_file."
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


pck()
{
    export PATH_CKPT=`pwd`
}

jck()
{
    cd $PATH_CKPT
}

vf()
{
    local file=$(fzf)
    if [[ -z "$file" ]]; then
        return
    fi
    vim $file
}

agopen()
{
    # use ag to search the content and open the file
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

_conf()
{
	_arguments '1: :(xmonad tmux vim nvim zsh zshbase zshal zshins conda)'
}

conf()
{
	case $1 in
		xmonad)		vim $HOME/.xmonad/xmonad.hs ;;
		tmux)		vim $HOME/.tmux.conf ;;
		vim)		vim $HOME/.vimrc ;;
		nvim)		vim $HOME/.config/nvim/init.vim ;;
		zsh)		vim $HOME/.zshrc ;;
		zshbase)    vim $HOME/.zsh/base.zsh ;;
		zshal)      vim $HOME/.zsh/alias.zsh ;;
		zshins)     vim $HOME/.zsh/install.zsh ;;
        conda)      vim $HOME/.condarc ;;
		*)		echo "Unknown application $1" ;;
	esac
}

duls()
{
    # list disk usage. use -r to show descending order
    local val="$(du -sk * | sort -n $1 | sed -E ':a; s/([[:digit:]]+)([[:digit:]]{3})/\1,\2/; ta')"
    local val="$(echo $val | head -n 10)"
    local val="$(echo $val | awk -F'\t' '{printf "%10s %s\n",$1,substr($0,length($1)+2)}')"
    echo $val
}

pypack()
{
    timelog "packing whl now..."
    python3 setup.py sdist bdist_wheel
    timelog "pack whl into dist directory done..."
}

rerun_check()
{
    # execute a command until it failed, log the count of run.
    eval "$1"
    local check="$?"
    local count=1

    while [ "$check" -eq 0 ]
    do
        eval "$1"
        check="$?"
        count=$(( count + 1 ))
    done
    timelog "total count:" $count
}
