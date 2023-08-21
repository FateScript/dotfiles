
os_install()
{
    local package_name=$1
    if [ "$OS_DISTRIBUTION" = "macos" ]; then
        brew install $package_name
    elif [ "$OS_DISTRIBUTION" = "ubuntu" ]; then
        sudo apt update
        sudo apt-get install -y $package_name
    fi
}

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

install_zsh_autojump()
{
    local autojump_path="$ZSH_CUSTOM/plugins/autojump"
    if [ -d "$autojump_path" ]; then
        echo "autojump already installed"
    else
        git clone https://github.com/wting/autojump.git $autojump_path
        cd $autojump_path
        ./install.py
    fi
}

install_zsh_autosuggest()
{
    local auto_suggest_path="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    if [ -d "$auto_suggest_path" ]; then
        echo "zsh-autosuggestions already installed"
    else
        git clone https://github.com/zsh-users/zsh-autosuggestions.git $auto_suggest_path
    fi
}

install_zsh_syntax_highlight()
{
    local syntax_highlight_path="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    if [ -d "$syntax_highlight_path" ]; then
        echo "zsh-syntax-highlighting already installed"
    else
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $syntax_highlight_path
    fi
}

install_zsh_fzf_tab()
{
    local fzf_tab_path="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab"
    if [ -d "$fzf_tab_path" ]; then
        echo "fzf-tab already installed"
    else
        git clone https://github.com/Aloxaf/fzf-tab  $fzf_tab_path
    fi
}

install_ohmyzsh()
{
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    install_zsh_autosuggest
    install_zsh_syntax_highlight
    install_zsh_autojump
    install_zsh_fzf_tab
}

update_conf()
{
    if ! [ -f "tmux.conf" ]; then
        echo "update_conf should be executed under the dofile dir."
        return
    fi
    cp tmux.conf $HOME/.tmux.conf
    if [ -d $HOME/.zsh ]; then
        echo "remove ~/.zsh dir"
        rm -rf $HOME/.zsh
    fi
    cp zshrc $HOME/.zshrc
    cp -r zsh $HOME/.zsh
    echo "update configure of zsh & tmux done"
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
        "$HOME"/.fzf/install
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

install_rg() { os_install ripgrep }

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
    pip install imgcat
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
