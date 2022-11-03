# aliases {
alias -g L="| less"
alias -g JL="| jq | less"
alias -g CL="| pygmentize | less"
alias -g G="| grep"
alias -g X="| xargs"

alias m="make"

alias sv="sudo vim"
alias vi="vim"
alias v=vim
alias c="cat"

alias ip3="python3 -c 'import IPython; IPython.terminal.ipapp.launch_new_instance()'"
alias pip3="python3 -m pip "
alias pip="python -m pip "

alias rf="readlink -f"

alias findname="find . -name"

# alternatives
alias alter_conf="sudo update-alternatives --config"
alias alter_install="sudo update-alternatives --install"

# kill process with python, run `pshow python KILL`
alias pshow="ps -ef | grep"
alias -g KILL="| awk '{print \$2}' | head -n -1 | xargs kill -9"

# diff dir a and b, run `diffdir a b DIFF`
alias diffdir="diff --exclude '*.txt' --exclude '*.pkl' --exclude '*__pycache__*'"
alias -g DIFF="--width=$COLUMNS --suppress-common-lines --side-by-side --recursive"

# tar aliases
alias tarinfo="tar -tf"
alias tarzip="tar -zcvf"
alias tarunzip="tar -zxvf"

# git aliases
alias gs="git status"
alias ga="git add"
alias gm="git commit -m"
alias gp="git push"
alias gd="git diff"
alias grm="git rm"
alias gmv="git mv"
alias gck="git checkout"
alias gr="git remote -v"
alias gdown="git reset HEAD"


if [ $OS_DISTRIBUTION = "arch" ]; then
	alias yS="yaourt -S --noconfirm --needed"
	alias ySs="yaourt -Ss"
	alias pS="sudo pacman -S --noconfirm --needed"
	alias pSs="sudo pacman -Ss"
fi

# }
