#!/usr/bin/env bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

export PATH="/opt/homebrew/bin:$PATH"

brew install coreutils gnu-tar gnu-find
brew install reattach-to-user-namespace tmux
brew install wget curl cmake htop axel
brew install node rust go

# tiling window manager + hotkey daemon
brew install koekeishiya/formulae/yabai koekeishiya/formulae/skhd
# Accessibility permission must be granted in System Settings before
# either service can actually work.
yabai --start-service || true
skhd --start-service || true

# cask app
brew install --cask iterm2 visual-studio-code \
    google-chrome clipy stats \
    iina anki notion eudic \
    netnewswire alt-tab
