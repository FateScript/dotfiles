
autoload -U compinit && compinit -u

safe_source() { [ -f  "$1" ] && source "$1" }

safe_source $HOME/.zsh/alias.zsh
safe_source $HOME/.zsh/base.zsh
safe_source $HOME/.zsh/install.zsh
safe_source $HOME/.zsh/git.zsh
safe_source $HOME/.zsh/venv.zsh
safe_source $HOME/.zsh/device.zsh

# compdef
compdef _src src
compdef _conf conf
compdef _act_venv act_venv rm_venv
compdef _bluetooth_device bluetooth_conn

compdef _git ga=git-add
compdef _git gc=git-commit
compdef _git gp=git-push
compdef _git gpp=git-pull
compdef _git gf=git-fetch
compdef _git gck=git-checkout
compdef _git gb=git-branch
compdef _git gr=git-remote
