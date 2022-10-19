
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

update_conf()
{
    cp tmux.conf ~/.tmux.conf
    if [ -d ~/.zsh ]; then
        echo "remove ~/.zsh dir"
        rm -rf ~/.zsh
    fi
    cp zshrc ~/.zshrc
    cp -r zsh ~/.zsh
}

install_fzf()
{
    if [ -d "$HOME/.fzf" ]; then
        echo "fzf already installed"
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install
    fi
}

install_ranger()
{
    local install_path
    install_path=~/.ranger
    if [ -d  $install_path ]; then
        echo "$install_path already existed"
    else
        git clone https://github.com/ranger/ranger.git $install_path
        pushd $install_path || exit
        sudo make install
        popd || exit
    fi
}

install_rg()
{
    sudo apt install -y ripgrep
}

install_ag()
{
    sudo apt install -y silversearcher-ag
}

install_fd()
{
    sudo apt install -y fd-find
    ln -s $(which fdfind) ~/.local/bin/fd
}

install_tools()
{
    sudo apt install -y tig
    sudo apt install -y htop
    sudo apt install -y jq
    sudo apt install -y shellcheck
    sudo apt install -y axel
    install_ag
    install_rg
    install_fzf
    install_ranger
}

install_all()
{
    prepare_tmux
    prepare_zsh
    install_tools
}
