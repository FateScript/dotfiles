# dotfiles

## Start configuration with a few steps
Step1: Clone this repo and enter the directory
```shell
git clone https://github.com/FateScript/dotfiles.git
cd dotfiles
```

Step2: Install
you can use the following command to install all the configuration files:
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
# or a lighter configuration with the following command [Suggested]
mv light_vimrc $HOME/.vimrc
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
