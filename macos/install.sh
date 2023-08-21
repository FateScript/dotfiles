#!/bin/env bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install coreutils gnu-tar gnu-find
brew install reattach-to-user-namespace tmux
brew install wget curl cmake htop the_silver_searcher
