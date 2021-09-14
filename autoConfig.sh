#!/usr/bin/env bash

prepare_flake8()
{
    pip3 install --user flake8
    cp flake8 ~/.flake8
}

prepare_tmux()
{
    sudo apt-get install tmux
    cp tmux.conf ~/.tmux.conf
}

prepare_zsh()
{
    sudo apt update
    sudo apt install -y zsh python-pygments autojump
    cp zshrc ~/.zshrc
    cp -r zsh ~/.zsh
    sudo chsh "$USER" -s /usr/bin/zsh
}

install_fzf()
{
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
}

install_extra_useful_tools()
{
    sudo apt install -y silversearcher-ag
    sudo apt install -y tig
    sudo apt install -y htop
    sudo apt install -y jq
    sudo apt install -y shellcheck
    install_fzf
}

prepare_flake8
prepare_tmux
prepare_zsh
install_extra_useful_tools
