#!/usr/bin/env bash

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

install_ranger()
{
    local install_path
    install_path=~/.ranger
    git clone https://github.com/ranger/ranger.git $install_path
    pushd $install_path
    sudo make install
    popd
}

install_extra_useful_tools()
{
    sudo apt install -y silversearcher-ag
    sudo apt install -y tig
    sudo apt install -y htop
    sudo apt install -y jq
    sudo apt install -y shellcheck
    # sudo apt install -y fd-find
    install_fzf
    install_ranger
}

prepare_tmux
prepare_zsh
install_extra_useful_tools
