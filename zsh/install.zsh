
prepare_tmux()
{
    os_install tmux
    cp tmux.conf ~/.tmux.conf
}

prepare_zsh()
{
    os_install zsh
    sudo apt install -y zsh python-pygments autojump
    install_ohmyzsh
    cp zshrc ~/.zshrc
    cp -r zsh ~/.zsh
    sudo chsh "$USER" -s /usr/bin/zsh
}

install_ohmyzsh()
{
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
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
    os_install ripgrep
}

install_fd()
{
    if [ "$OS_DISTRIBUTION" = "macos" ]; then
        brew install fd
    elif [ "$OS_DISTRIBUTION" = "ubuntu" ]; then
        sudo apt install -y fd-find
        ln -s $(which fdfind) ~/.local/bin/fd
    fi
}

install_tools()
{
    os_install tig
    os_install htop
    os_install jq
    os_install shellcheck
    os_install axel
    install_ag
    install_rg
    install_fzf
    install_ranger
}

install_py_pack()
{
    python3 -m pip install --upgrade setuptools wheel twine
}

install_all()
{
    prepare_tmux
    prepare_zsh
    install_tools
}
