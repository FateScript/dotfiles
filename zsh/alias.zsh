
# global aliases
alias -g L="| less"
alias -g JL="| jq | less"
alias -g CL="| pygmentize | less"
alias -g X="| xargs"
alias -g B='|sed -r "s:\x1B\[[0-9;]*[mK]::g"'       # remove color, make things boring
alias -g N='>/dev/null'
alias -g NN='>/dev/null 2>&1'
alias -g F="| fzf"
alias -g H="--help"

which tac NN && {
    alias -g R="| tac"
} || {
    alias -g R="| tail -r"
}

which python NN || alias python="python3"

which rg NN && {
    alias -g G='| rg'
    alias ag='rg -i'
    alias agp='rg -i -tpy'
} || {
    which ag NN && {
        alias -g G='| ag'
        alias agp='ag --python'
    } || alias -g G='| grep'
}

which pbcopy NN && {
    alias -g C="| pbcopy"
    function copy() { cat "${1:-/dev/stdin}" | pbcopy; }
} || {
    which xclip NN && {
        alias -g C='| xclip -selection clipboard'
        function copy() { cat "${1:-/dev/stdin}" | xclip -selection clipboard -in &>/dev/null &|; }
    } || {
        alias copy="yank"
        alias -g C='| yank'
    }
}

which nvidia-smi NN && {  # https://github.com/ppwwyyxx/dotfiles/blob/6f3985ad81d4113f57532fbf60d6b2b6214a5d04/.zsh/alias.zsh#L427-L432
    alias __nvq='nvidia-smi --query-gpu=temperature.gpu,clocks.current.sm,pstate,power.draw,utilization.gpu,utilization.memory,memory.free --format=csv | tail -n+2'
    which nl NN && {
        alias nvq='(echo "GPU,temp, clocks, pstate, power, util.GPU, util.MEM, freeMEM" && __nvq | nl -s, -w1 -v0) | column -t -s, | colorline'
    } || {
        alias nvq='(echo "temp, clocks, power, util.GPU, util.MEM, freeMEM" && __nvq) | column -t -s , | colorline'
    }
    alias __nvp="nvidia-smi | awk '/GPU.*PID/ { seen=1 }; /==========/{if (seen) pp=1; next} pp ' \
        | head -n-1  |  awk '{print \$2, \$(NF-1), \$3 == \"N/A\" ? \$5 : \$3}' \
        | grep -v '^No' \
        | awk 'BEGIN{OFS=\"\\t\"} { cmd=(\"ps -ho '%a' \" \$3); cmd | getline v; close(cmd); \$4=v; print }'"
    alias nvp="(echo \"GPU\tMEM\tPID\tCOMMAND\" && __nvp) | column -t -s $'\t' | cut -c 1-\$(tput cols) | colorline"
    alias nvpkill="nvp | awk '{print \$3}' | tail -n+2 | xargs -I {} sh -c 'echo Killing {}; kill {} || echo failed'"
    alias fuser-nvidia-kill="fuser -v /dev/nvidia* 2>&1 | egrep -o '$USER.*[0-9]+ .*'  | awk '{print \$2}' | xargs -I {} sh -c 'echo Killing {}; kill {} || echo failed'"
}

which dc NN || alias dc="cd"  # miss-type correction

# file
alias 'rm!'="rm -rf"
alias rm="rm -r"
alias cp="cp -r"
alias sv="sudo vim"
alias vi="vim"
alias v="vim"
alias c="cat"
alias icat="imgcat"
alias rp="realpath"
alias rf="readlink -f"
alias findname="find . -name"
alias latest='ls -lt | head -n 2 | awk '\''NR==2{print $NF}'\'

# clipboard
alias cp_latest='echo $(latest) | yank'

alias nohistory='unset HISTFILE'

## diff dir a and b, run `diffdir a b DIFF`
alias diffdir="diff --exclude '*.txt' --exclude '*.pkl' --exclude '*__pycache__*'"
alias -g DIFF='--width="$COLUMNS" --suppress-common-lines --side-by-side --recursive'

## tar aliases
alias tarinfo="tar -tf"
alias tarzip="tar -zcvf"
alias tarunzip="tar -zxvf"

# system
alias watch='watch '  # allow watching an alias in some cases
alias cn_tz="TZ=Asia/Shanghai date"  # cn time zone
alias zh_cn="LC_ALL='zh_CN.UTF-8'"  # encode
alias cursor="echo -e '\033[?25h'"
alias which="which -a"
alias m="make"
alias font="fc-list :lang=zh"

## pretty print the $PATH
alias path='echo $PATH | tr -s ":" "\n"'
alias pck='export PATH_CKPT="$(pwd)"'
alias jck='cd "$PATH_CKPT"'

# search
alias search_alias='alias | grep'

## alternatives
alias alter_conf="sudo update-alternatives --config"
alias alter_install="sudo update-alternatives --install"

# process
## for example, to kill process with python, run `pshow python KILL`
alias pshow="ps -ef | grep"
alias psfzf="ps -ef | fzf --bind 'ctrl-r:reload(ps -ef)' \
      --header 'Press CTRL-R to reload' --header-lines=1 \
      --height=50% --layout=reverse"
alias -g KILL="| awk '{print \$2}' | head -n 1 | xargs kill -9"

# sync
alias scp="scp -r"
alias rsync="rsync -avP"

# python
alias ip3="python3 -c 'import IPython; IPython.terminal.ipapp.launch_new_instance()'"
alias pip3="python3 -m pip "
alias pip="python -m pip "
alias pip_tuna="pip install -i https://pypi.tuna.tsinghua.edu.cn/simple"
alias pip_ins="pip install -v -e ."
alias pip_ins_compat="pip install -e . --config-settings editable_mode=compat"
alias pdbtest="pytest --pdb --pdbcls=IPython.terminal.debugger:Pdb -s"
alias nb2py="jupyter nbconvert --to script"

alias upip="uv pip"
alias usrc="source .venv/bin/activate"

# git aliases, see https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git for more
alias gmm="git commit --amend"  # git message modification
alias gad='git add $(git ls-files --deleted)'
alias grt='cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"'  # override
alias gcf_mir='git config --global url."https://gitclone.com/".insteadOf https://'
alias gcf_rst_mir='git config --global --unset url.https://gitclone.com/.insteadOf'
alias git_ls_unreachable='git fsck --unreachable --no-reflog'
alias gsbi="git submodule update --init --recursive"
alias gign="git ls-files --others --ignored --exclude-standard"
alias gclean_check="git clean -nd"

# git proxy
alias git_proxy_on='git config --global http.proxy 127.0.0.1:7890 && git config --global https.proxy 127.0.0.1:7890'
alias git_proxy_off='git config --global --unset http.proxy && git config --global --unset https.proxy'

# git branchless
alias gbls="git branchless"
alias gb_init="git branchless init --main-branch "
alias gb_unin="git branchless init --uninstall"
alias gbp="git prev"
alias gbn="git next"
alias gsl="git sl"  # smart log
alias gmv="git move"  # smart log
alias gin="git move --insert --exact"  # git insert a commit
alias grsk="git restack"
alias gfup="git fixup"
alias ghd="git hide"
alias guhd="git unhide"
alias ggo="git sw -i"  # git go to switch commit when using branchless
alias gsp="git_branch_push"  # short for super push, used for git branchless
alias gsy="git sync --pull"

# cargo
alias install_delta="cargo install git-delta"
alias install_branchless="cargo install --locked git-branchless"

# curl
alias install_ollama="curl -fsSL https://ollama.com/install.sh | sh"

# download
alias vget="you-get"
alias vgetl="you-get --playlist"

# tmux alias
alias ta="tmux a || tmux"
alias tn="tmux new -s"

# OS specific aliases
if [ "$OS_DISTRIBUTION" = "arch" ]; then
	alias yS="yaourt -S --noconfirm --needed"
	alias ySs="yaourt -Ss"
	alias pS="sudo pacman -S --noconfirm --needed"
	alias pSs="sudo pacman -Ss"
elif [ "$OS_DISTRIBUTION" = "macos" ]; then   # MacOS specific aliases
    # example: app_name /Applications/Visual\ Studio\ Code.app
    alias app_name="mdls -name kMDItemCFBundleIdentifier"
fi
