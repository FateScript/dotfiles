# dotfiles
日常使用Ubuntu的一些配置文件，git clone之后解压使用

## Use script to config
运行autoConfig.sh即可一键配置，推荐vm或者实体机器使用，如果是workspace下推荐自由配置
```shell
./autoConfig.sh
```
如果需要个性化配置请阅读如下部分
## Vim Configuration
将vimconf文件改为.vimrc，然后移动到home里面
```shell
mv vimrc $HOME/.vimrc
```
如果想要配置的比较简单，可以使用light_vimrc
```shell
mv light_vimrc $HOME/.vimrc
```
如果需要使用vim的各种插件，需要安装vundle
如果不需要，请将.vimrc中的插件配置部分注释掉

安装Vundle
```shell
git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
```
启动vim并且在vim下运行 **:PluginInstall**
如果安装的插件比较多的话，需要等待的时间也相对比较长一些

## Install Vim Plugin

#### Vim Plugin
打开vim，输入
```
:PluginInstall
```
#### LSP
在完成LSP的安装之后，在vim的命令模式下，输入
```
:LspInstallServer
```

## Oh-my-zsh Configuration
首先需要安装zsh以及一些依赖
```shell
sudo apt update
sudo apt install -y zsh python-pygments autojump

cp -r zsh $HOME/.zsh
cp zshrc $HOME/.zshrc
```
运行zsh
```shell
zsh
```
将zsh设置为默认的shell
```shell
sudo chsh $USER -s /usr/bin/zsh
```
这样就完成了zsh的配置

## Tmux Configuration
首先需要安装tmux
```shell
sudo apt-get install tmux
```
之后将tmux.conf文件移动到home文件夹之下并重命名为.tmux.conf
```shell
mv tmux.conf $HOME/.tmux.conf
```
配置完成
