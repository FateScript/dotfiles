# dotfiles

## Start configuration with a few steps
Step1: Clone this repo and enter the directory
```shell
git clone https://github.com/FateScript/dotfiles.git
cd dotfiles
```

Step2: Install (one-click)
This installs zsh/tmux/tools, oh-my-zsh with plugins, deploys all the
configuration files, and sets zsh as your default shell:
```shell
./install.sh
```

Alternatively, you can source the install script and call the functions you need:
```shell
source zsh/install.zsh
install_all
```

Step3: Update configuration if needed
If you have install the software, you can use the following command to update the configuration files:
```shell
update_conf
```

## Customize your configuration if needed

### Vim

Step1: Move vimrc to $HOME/.vimrc
```shell
mv vimrc $HOME/.vimrc
```

Step2: Install vim-plug

Start vim and run the following command in command mode:
```shell
:PluginInstall
```

### Oh-my-zsh

Install and configure zsh, and set zsh as default shell.

```shell
prepare_zsh
```

### Tmux

Install and configure tmux.

```shell
prepare_tmux
```

### Useful tools 

* [ranger](https://github.com/ranger/ranger)
* [ripgrep](https://github.com/BurntSushi/ripgrep)
* [mdcat](https://github.com/BIRSAx2/mdcat) for rendering Markdown in the terminal
* [fzf](https://github.com/junegunn/fzf)
* [timg](https://github.com/hzeller/timg) or [imgcat](https://github.com/wookayin/python-imgcat)

```shell
install_tools
```

### VSCode
Highly recommend to use [vscode](https://code.visualstudio.com/) + [vim plugin](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim) as your working IDE.

For more settings, please refer to [vscode config](vscode/README.md)

### Surfingkeys
[Surfingkeys](https://github.com/brookhong/Surfingkeys) is a chrome extension that provides vim-like keybindings in chrome.

### Acknowledgement

I refer to the following repos to build my own dotfiles:
* [dotfiles of kdeldycke](https://github.com/kdeldycke/dotfiles)
* [dotfiles of ppwwyyxx](https://github.com/ppwwyyxx/dotfiles)
