#!/bin/env bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install coreutils gnu-tar gnu-find
brew install reattach-to-user-namespace tmux
brew install wget curl cmake htop the_silver_searcher

# cask app
brew install --cask iterm2
brew install --cask visual-studio-code
brew install --cask google-chrome
brew install --cask clipy
brew install --cask clashx
brew install --cask stats
brew install --cask iina
brew install --cask anki
brew install --cask notion
brew install --cask eudic
brew install --cask netnewswire
