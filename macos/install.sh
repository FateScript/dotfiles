#!/bin/env bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install coreutils gnu-tar gnu-find
brew install reattach-to-user-namespace tmux
brew install wget curl cmake htop axel
brew install node rust go

# cask app
brew install --cask iterm2 visual-studio-code \
    google-chrome clipy clashx stats \
    iina anki notion eudic \
    netnewswire alt-tab
