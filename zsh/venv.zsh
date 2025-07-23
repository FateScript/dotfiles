VENV_DIR="$HOME/workspace/env"

create_venv() {
    local type
    local name

    case "$1" in
        uv|py|conda)
            type="$1"
            name="$2"
            ;;
        *)
            type="uv"
            name="$1"
            ;;
    esac

    if [[ -z "$name" ]]; then
        echo "Usage: create_venv [uv|py|conda] <env_name>"
        return 1
    fi

    local venv_path="$VENV_DIR/$name"
    echo "Creating" ${type} "virtual environment at $venv_path"

    case "$type" in
        py)
            python3 -m venv "$venv_path"
            ;;
        uv)
            uv venv "$venv_path"
            ;;
        conda)
            conda create -y -p "$venv_path"
            ;;
        *)
            echo "Unsupported type: $type"
            echo "Supported types: uv, py, conda"
            return 1
            ;;
    esac
}

_create_venv() {
    local -a types
    types=("uv" "py" "conda")

    if [[ ${CURRENT} -eq 2 ]]; then
        # Completing the first argument: type
        compadd "${types[@]}"
    elif [[ ${CURRENT} -eq 3 ]]; then
        # Completing the second argument: env name (no suggestions, just filename-style)
        _files
    fi
}

rm_venv()
{
    rm -rf "$VENV_DIR"/"$1"
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

deact() {
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
    fi
    while [ -n "$CONDA_DEFAULT_ENV" ]; do
        conda deactivate
    done
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
