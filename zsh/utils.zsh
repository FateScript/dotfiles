
get_os_distribution() {
	awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }'
}

OS_DISTRIBUTION=$(get_os_distribution)

act_venv() {
    if [ $1 -e ]
    source ~/env/$1/bin/activate
}

tmux_venv() {
    tmux set-env VIRTUAL_ENV $VIRTUAL_ENV
}

tmux_rm_venv() {
    tmux set-env -r VIRTUAL_ENV
}
