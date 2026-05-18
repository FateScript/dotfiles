
os_install()
{
    local package_name="$1"
    if [ "$OS_DISTRIBUTION" = "macos" ]; then
        brew install "$package_name"
    elif [ "$OS_DISTRIBUTION" = "ubuntu" ]; then
        sudo apt update
        sudo apt-get install -y "$package_name"
    fi
}

prepare_tmux()
{
    os_install tmux
    cp tmux.conf "$HOME/.tmux.conf"
}

prepare_zsh()
{
    os_install zsh
    install_ohmyzsh
    cp zshrc "$HOME/.zshrc"
    mkdir -p "$HOME/.zsh"
    cp -r zsh/. "$HOME/.zsh/"

    local zsh_path
    zsh_path="$(command -v zsh)"
    if ! grep -qx "$zsh_path" /etc/shells; then
        echo "$zsh_path is not listed in /etc/shells. Add it before running chsh."
        return 1
    fi
    sudo chsh -s "$zsh_path" "$USER"
}

install_zsh_autojump()
{
    local autojump_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autojump"
    if [ -d "$autojump_path" ]; then
        echo "autojump already installed"
    else
        git clone https://github.com/wting/autojump.git "$autojump_path"
        cd "$autojump_path" || return
        ./install.py
    fi
}

install_zsh_autosuggest()
{
    local auto_suggest_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    if [ -d "$auto_suggest_path" ]; then
        echo "zsh-autosuggestions already installed"
    else
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$auto_suggest_path"
    fi
}

install_zsh_syntax_highlight()
{
    local syntax_highlight_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    if [ -d "$syntax_highlight_path" ]; then
        echo "zsh-syntax-highlighting already installed"
    else
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$syntax_highlight_path"
    fi
}

install_zsh_fzf_tab()
{
    local fzf_tab_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
    if [ -d "$fzf_tab_path" ]; then
        echo "fzf-tab already installed"
    else
        git clone https://github.com/Aloxaf/fzf-tab "$fzf_tab_path"
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

install_miniconda()
{
    local install_dir
    if [[ "$(uname)" == "Darwin" ]]; then  # macOS
        install_dir="$HOME/miniconda3"
        mkdir -p "$install_dir"
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o "$install_dir/miniconda.sh"
        bash "$install_dir/miniconda.sh" -b -u -p "$install_dir"
        rm -rf "$install_dir/miniconda.sh"
    elif [[ "$(uname)" == "Linux" ]]; then  # Linux
        install_dir="$HOME/miniconda3"
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$install_dir.sh"
        bash "$install_dir.sh" -b -p "$install_dir"
        rm "$install_dir.sh"
    else
        echo "Unsupported OS: $(uname)"
        return 1
    fi
    "$install_dir/bin/conda" init zsh
}

install_fzf()
{
    if [ -d "$HOME/.fzf" ]; then
        echo "fzf already installed"
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME"/.fzf/install
    fi
}

install_ranger()
{
    local install_path
    install_path=$HOME/.ranger
    if [ -d "$install_path" ]; then
        echo "$install_path already existed"
    else
        git clone https://github.com/ranger/ranger.git "$install_path"
        pushd "$install_path" || return
        sudo make install
        popd || return
    fi
}

install_fd()
{
    if [ "$OS_DISTRIBUTION" = "macos" ]; then
        brew install fd
    elif [ "$OS_DISTRIBUTION" = "ubuntu" ]; then
        sudo apt install -y fd-find
        mkdir -p "$HOME/.local/bin"
        ln -s "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi
}

install_tools()
{
    os_install tig
    os_install htop
    os_install jq
    os_install shellcheck
    os_install rsync
    os_install axel
    os_install ripgrep
    os_install ncdu

    pip install imgcat
    pip install nvitop
    pip install py-spy
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

omz_complete()
{
    cp "$ZSH/plugins/docker/completions/_docker" "$ZSH_CACHE_DIR/completions"
    cp "$HOME/.zsh/Completion/_conda" "$ZSH_CACHE_DIR/completions"
}

update_conf()
{
    if ! [ -f "tmux.conf" ]; then
        echo "update_conf should be executed under the dotfile dir."
        return
    fi

    # tmux and zsh
    cp tmux.conf "$HOME/.tmux.conf"
    if [ -d "$HOME/.zsh" ]; then
        echo "clean $HOME/.zsh dir (preserving Completion)"
        find "$HOME/.zsh" -mindepth 1 -maxdepth 1 ! -name Completion -exec rm -rf {} +
    fi
    cp zshrc "$HOME/.zshrc"
    mkdir -p "$HOME/.zsh" "$HOME/.zsh/Completion"
    cp -r zsh/. "$HOME/.zsh/"
    cp py_completions/_* "$HOME/.zsh/Completion/" 2>/dev/null
    find py_completions -mindepth 2 -maxdepth 2 -type f -name "_*" -exec cp {} "$HOME/.zsh/Completion/" \;

    if ! [ -f "$HOME/.zsh.local" ]; then
        echo "update zsh.local, for local usage"
        cp zsh.local "$HOME/.zsh.local"
    fi
    echo "update configure of zsh & tmux done"

    # python startup
    echo "update $HOME/.python_startup.py, for python startup"
    cp python/startup.py "$HOME/.python_startup.py"

    # local scripts
    bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"
    cp scripts/* "$bin_dir/"
    echo "update scripts in $bin_dir"
}
