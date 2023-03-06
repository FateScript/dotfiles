
prepare_tmux()
{
    os_install tmux
    cp tmux.conf $HOME/.tmux.conf
}

prepare_zsh()
{
    os_install zsh
    install_ohmyzsh
    cp zshrc $HOME/.zshrc
    cp -r zsh $HOME/.zsh
    sudo chsh "$USER" -s /usr/bin/zsh
}

install_ohmyzsh()
{
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    local auto_suggest_path="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    if [ -d "$auto_suggest_path" ]; then
        echo "zsh-autosuggestions already installed"
    else
        git clone auto_suggest_path
    fi

    local syntax_highlight_path="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    if [ -d "$syntax_highlight_path" ]; then
        echo "zsh-syntax-highlighting already installed"
    else
        git clone syntax_highlight_path
    fi
}

update_conf()
{
    cp tmux.conf $HOME/.tmux.conf
    if [ -d $HOME/.zsh ]; then
        echo "remove ~/.zsh dir"
        rm -rf $HOME/.zsh
    fi
    cp zshrc $HOME/.zshrc
    cp -r zsh $HOME/.zsh
}

install_fzf()
{
    if [ -d "$HOME/.fzf" ]; then
        echo "fzf already installed"
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        $HOME/.fzf/install
    fi
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
    install_path=$HOME/.ranger
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
        ln -s $(which fdfind) $HOME/.local/bin/fd
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
