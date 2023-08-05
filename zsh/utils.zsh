
safe_source()
{
    [ -f  "$1" ] && source "$1"
}

safe_source $HOME/.zsh/alias.zsh
safe_source $HOME/.zsh/base.zsh
safe_source $HOME/.zsh/install.zsh
safe_source $HOME/.zsh/git.zsh
safe_source $HOME/.zsh/venv.zsh
