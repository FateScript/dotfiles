
# default beginning-of-line is ctrl-a, which conflicted with keybinding ctrl-a
# used in tmux. 
bindkey '^D' beginning-of-line  # Bind Ctrl + D to beginning-of-line
bindkey '^F' forward-word  # Bind Ctrl + F to forward-word
bindkey '^B' backward-word  # Bind Ctrl + B to backward-word
bindkey '^H' backward-char
bindkey '^L' forward-char

# plugins
autoload -Uz jump-target
zle -N jump-target
bindkey "^J" jump-target  # using ctrl+j to jump to target character
