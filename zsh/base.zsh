
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

timelog()
{
    # log related function with timestamp
    local now=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "\033[32m$now\033[0m" "$@"
}

warnlog() { echo -e "\033[31m$@\033[0m" }

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

compress_dir() {
    # usage: compress_dir <dir>
    if [[ ! -d $1 ]]; then
        echo "$1 is not a directory"
        exit
    fi
    local name=$1
    # tar czvf ${name%/}.tgz $1 && rm -rf $1
    tar czvf ${name%/}.tgz $1
}

sdu () {
    # usage: sdu <dir>
    # reverse sort by size: sdu <dir> -r
    local args="${@:2}"
    local should_pop=1
    if [[ "$#" -eq 1 ]]; then
        if [[ -d "$1" ]]; then
            pushd "$1" >/dev/null
        else
            args="${@:1}"
            should_pop=0
        fi
    elif [[ "$#" -eq 0 ]]; then
        should_pop=0
    else
        pushd "$1" >/dev/null
    fi

    du -sh {*,} 2>/dev/null | sort -h $args

    if [[ "$should_pop" -eq 1 ]]; then
        popd >/dev/null
    fi
}

cdw() { cd $(dirname $(which $1)) }

cdd() { cd $(dirname $1) }

cdfzf()
{
    local file=$(fzf)
    if [[ -z "$file" ]]; then
        return
    fi
    cd $(dirname $(realpath $file))
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
        echo "Usage: src <function_name | alias name>"
        return 1
    fi

    local func_code
    func_code=$(functions "$func_name")

    if [[ -z "$func_code" ]]; then
        (( $+aliases[$func_name] )) && echo $aliases[$func_name]
        return
    fi

    local type_info=$(type "$func_name")
    func_code=$(echo "$func_code" | expand -t 4)
    echo "$type_info"
    echo "$func_code"
}

_src() {
    local completions

    # Collect all aliases and functions and store them in the 'completions' array
    completions=(${(k)aliases} ${(k)functions})

    # Generate completions using the _values function
    _values 'src completions' $completions
}

softlinks() {
    # usage: softlinks <source_folder> [dest_folder]
    local source_folder=$(realpath "$1")
    local dest_folder="$2"

    if [[ -z "$dest_folder" ]]; then
        dest_folder=$(basename "$source_folder")
    fi

    if [[ ! -d "$source_folder" ]]; then
        echo "Source folder does not exist: $source_folder"
        return 1
    fi

    if [[ ! -d "$dest_folder" ]]; then
        mkdir -p "$dest_folder"
    fi

    for src_file in "$source_folder"/*; do
        if [[ -f "$src_file" ]]; then
            file_name=$(basename "$src_file")
            symlink_path="$dest_folder/$file_name"
            ln -s "$src_file" "$symlink_path"
            echo "Created a symbolic link: $symlink_path -> $src_file"
        fi
    done
}


search_funcs() {
    # search functions whose value contains search string
    # example usage: search_funcs "git"
    local search_string="$1"
    local function_name function_source

    for function_name in ${(k)functions}; do
    function_source="${functions[$function_name]}"
    if [[ $function_source == *$search_string* ]]; then
        echo "$function_name"
    fi
    done
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

vf()
{
    local file=$(fzf)
    if [[ -z "$file" ]]; then
        return
    fi
    vim $file
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

_conf() { _arguments '1: :(xmonad tmux vim nvim zsh zshbase zshal zshins zshlocal conda ssh py)' }

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
        zshins)     vim $HOME/.zsh/install.zsh;;
        zshlocal)   vim $HOME/.zsh.local;;
        conda)      vim $HOME/.condarc ;;
        ssh)        vim $HOME/.ssh/config;;
        py)         vim $HOME/.python_startup;;
        *)		echo "Unknown application $1" ;;
	esac
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

retry()
{
    # execute a command until it success, log the count of rerun.
    eval "$1"
    local check="$?"
    local count=1

    while [ "$check" -ne 0 ]
    do
        warnlog "rerun the command: $1"
        eval "$1"
        check="$?"
        count=$(( count + 1 ))
    done
    timelog "total count:" $count
}

lines() {
    # Usage: lines <file> <line_number>
    # For example: `lines file.txt 22,25` `lines file.txt 24`
    if [ $# -lt 2 ]; then
        echo "Usage: display_lines <file> <lines>"
        return 1
    fi

    local file="$1"
    local lines="$2"

    sed -n "$lines p" "$file"
}

p() {
    # Execute the previous commands. Useage: p <number> or p
    local num=${1:-1}  # Get the input argument or default to 1
    if ! [[ $num =~ ^[0-9]+$ ]]; then
        num=1  # Fallback to 1 if the input is not a number
    fi
    local commands=()

    # Loop through history in reverse to find the last non-'p' and non-'clear' commands
    for (( i = 1; i <= HISTCMD; i++ )); do
        local cmd=$(history -n -$i | head -n 1 | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//')
        if ! [[ $cmd =~ ^p\ + || $cmd == "p" || $cmd == "clear" ]]; then
            commands=($cmd "${commands[@]}")
            if [[ ${#commands[@]} -eq $num ]]; then
                break
            fi
        fi
    done

    # If non-'p' and non-'clear' commands are found, execute them
    if [[ ${#commands[@]} -gt 0 ]]; then
        timelog "Executing previous $num commands."
        for cmd in "${commands[@]}"; do
            timelog "Executing: $cmd"
            eval $cmd
        done
    else
        warnlog "No previous commands found."
    fi
}

# ANSI escape code related functions
# learn more at https://en.wikipedia.org/wiki/ANSI_escape_code

pipe_clip()
{
    # Copy the input to the clipboard, when pbcopy/xclip is not available
    # Example: echo "hello" | pipe_clip
    # The terminal should support OSC 52 escape sequence protocol
    local input=$(cat)
    printf "\e]52;c;$(echo $input | base64)\a"
}

dedup_path() {
    # dedup dir variable of path env
    local dedup_path=""
    for prev_path in `echo $PATH | tr -s ":" "\n"`; do
        if [[ ":$dedup_path:" != *":$prev_path:"* ]]; then
            [[ -z "$dedup_path" ]] && dedup_path="$prev_path" || dedup_path="$dedup_path:$prev_path"
        else
            echo "dup path:" $prev_path
        fi
    done
    export PATH="$dedup_path"
}

remove_path() {
    # rm dir variable of path env
    local new_path=""
    for prev_path in `echo $PATH | tr -s ":" "\n"`; do
        if [[ "$prev_path" != "$1" ]]; then
            [[ -z "$new_path" ]] && new_path="$prev_path" || new_path="$new_path:$prev_path"
        else
            echo "rm" $prev_path "from PATH"
        fi
    done
    export PATH="$new_path"
}

pylibinfo() {
  if [[ -z "$1" ]]; then echo "Usage: pylibinfo libname"; return; fi
  python -c "import $1 as X; print(X.__file__, end=' '); print(X.__version__)"
}

function sftp_upload {
    # sftp_upload <server_name> <local_file_or_directory> [remote_path]
    # Example usage:
    # sftp_upload server_name /path/to/local_file_or_directory /path/to/remote_directory
    # If the remote path is not provided, it will default to login path
    # This function should be used when rsync is not available

    if [[ $# -lt 2 ]]; then
        echo "Usage: sftp_upload <server_name> <local_file_or_directory> [remote_path]"
        return 1
    fi

    local server_name=$1
    local local_path=$2
    local remote_path=${3:-""}

    if [[ ! -e $local_path ]]; then
        echo "Local file or directory does not exist: $local_path"
        return 1
    fi

    echo "Uploading $local_path to $server_name:$remote_path"

    # Use sftp to upload the file or directory to the remote server
    sftp "$server_name" <<EOF
        put -rf "$local_path" "$remote_path"
        exit
EOF
}

_sftp_upload() {
    local -a servers
    servers=($(cat ~/.ssh/config | grep 'Host ' | sed 's/Host //'))

    case $words[2] in
        (*)
            _arguments \
                "1:Server Name:($servers)" \
                '2:Local File or Directory:_path_files' \
                '3:Remote Path:_files'
            ;;
    esac
}
