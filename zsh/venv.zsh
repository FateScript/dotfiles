VENV_DIR="$HOME/workspace/env"

create_venv()
{
    python3 -m venv "$VENV_DIR"/"$1"
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
