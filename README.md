# MyConf
日常使用Ubuntu的一些配置文件，git clone之后解压使用

## Vim Configuration
将vimconf文件改为.vimrc，然后移动到home里面
```shell
mv vimrc ~/.vimrc
```
如果需要使用vim的各种插件，需要安装vundle
如果不需要，请将.vimrc中的插件配置部分注释掉

安装Vundle
```shell
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```
启动vim并且在vim下运行 **:PlugInstall**

## Oh-my-zsh Configuration
首先需要安装zsh以及一些依赖
```
sudo apt update
sudo apt install -y zsh python-pygments autojump
```
之后在home目录解压zsh.tar.gz

```shell
cd ~
tar xvf ~/Downloads/zsh.tar.gz
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
mv tmux.conf ~/.tmux.conf
```
配置完成