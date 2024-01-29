
# default beginning-of-line is ctrl-a, which conflicted with keybinding ctrl-a
# used in tmux. 
bindkey -r "^D"
_exit_zsh_if_empty() {
  if [[ -z $BUFFER ]]; then exit; fi
}
zle -N _exit_zsh_if_empty
bindkey '^D' _exit_zsh_if_empty

# navigate words
# ctrl + a/e for beginning/end of line
# ctrl + p/n for previous/next command
# ctrl + m for enter
# ctrl + k for kill line
bindkey '^F' forward-word
bindkey '^B' backward-word
bindkey '^H' backward-char
bindkey '^L' forward-char
bindkey '^?' backward-delete-char
bindkey "^X^X" backward-delete-char

# plugins
autoload -Uz jump-target
zle -N jump-target
bindkey "^J" jump-target  # using ctrl+j to jump to target character
