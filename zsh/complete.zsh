
# .... path completion
__expand_dots() {
    # add / after sequence of ......, if not there
    local cur=`echo "$1" | sed 's/\( \|^\)\(\.\.\.\.*\)\([^\/\.]\|$\)/\1\2\/\3/g'`
    while true; do  # loop to expand ...
        local new=`echo $cur | sed 's/\.\.\./\.\.\/\.\./g'`
        if [[ $new == $cur ]]; then
            break
        fi
        cur=$new
    done
    BUFFER=$cur
}

__user_complete(){
    # In the context of zsh and its line editor (zle)
    # $BUFFER is a special variable that holds the current contents of the command line.
    # This includes whatever the user has typed before pressing a key bound to a custom function or widget.
    if [[ -z $BUFFER ]]; then
        return
    fi
    if [[ $BUFFER =~ "^\.\.\.*$" ]]; then
        __expand_dots "$BUFFER"
        zle end-of-line
        return
    elif [[ $BUFFER =~ ".* \.\.\..*$" ]] ;then
        __expand_dots "$BUFFER"
        zle end-of-line
        return
    fi
    # try to use fzf-tab and fzf if available
    if [[ -n ${+functions[fzf-tab-complete]} ]] && command -v fzf >/dev/null; then
        zle fzf-tab-complete
    else  # fallback to normal
        zle expand-or-complete
    fi
}

fzf_tab_off() {
    unfunction __user_complete 2>/dev/null
    unfunction fzf_tab_on 2>/dev/null  # remove previous toggle if any

    __user_complete() {
        if [[ -z $BUFFER ]]; then
            return
        fi

        if [[ $BUFFER =~ "^\.\.\.*$" || $BUFFER =~ ".* \.\.\..*$" ]]; then
            __expand_dots "$BUFFER"
            zle end-of-line
            return
        fi

        zle expand-or-complete
    }
    zle -N __user_complete
    bindkey '^I' __user_complete

    echo "fzf-tab-complete is OFF"

    # Provide way to toggle it back on
    fzf_tab_on() {
        unfunction __user_complete 2>/dev/null

        __user_complete() {
            if [[ -z $BUFFER ]]; then
                return
            fi

            if [[ $BUFFER =~ "^\.\.\.*$" || $BUFFER =~ ".* \.\.\..*$" ]]; then
                __expand_dots "$BUFFER"
                zle end-of-line
                return
            fi

            if (( $+functions[fzf-tab-complete] )) && command -v fzf >/dev/null; then
                zle fzf-tab-complete
            else
                zle expand-or-complete
            fi
        }
        zle -N __user_complete
        bindkey '^I' __user_complete

        echo "fzf-tab-complete is ON"
    }
}

zle -N __user_complete
bindkey "\t" __user_complete  # bind tab
autoload compinstall  # lazy load zsh's completion system

# file completion ignore
zstyle ':completion:*:*:*vim:*:*files' ignored-patterns '*.(avi|mkv|rmvb|pyc|wmv|mp3|mp4|pdf|doc|docx|jpg|png|bmp|gif|npy|bin|o)'
zstyle ':completion:*:git-branchless:*' sort false
