
get_os_distribution() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }'
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        echo "ID=macos" | awk -F'=' '{ print tolower($2) }'
    fi
}

OS_DISTRIBUTION=$(get_os_distribution)

act_venv() {
    source ~/env/$1/bin/activate
}

tmux_venv() {
    tmux set-env VIRTUAL_ENV $VIRTUAL_ENV
}

tmux_rm_venv() {
    tmux set-env -r VIRTUAL_ENV
}
