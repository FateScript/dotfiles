# MyConf
日常使用Ubuntu的一些配置文件，git clone之后解压使用
## Use script to config
运行autoConfig.sh即可一键配置，推荐vm或者实体机器使用，如果是workspace下推荐自由配置
```shell
chmod +x autoConfig.sh
./autoConfig.sh
```
如果需要个性化配置请阅读如下部分
## Vim Configuration
将vimconf文件改为.vimrc，然后移动到home里面
```shell
mv vimrc ~/.vimrc
```
如果想要配置的比较简单，可以使用light_vimrc
```shell
mv light_vimrc ~/.vimrc
```
如果需要使用vim的各种插件，需要安装vundle
如果不需要，请将.vimrc中的插件配置部分注释掉

安装Vundle
```shell
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```
启动vim并且在vim下运行 **:PluginInstall**
如果安装的插件比较多的话，需要等待的时间也相对比较长一些

## Install Vim Plugin

####You Complete Me
为了使用YouCompleteMe(YCM)需要我们手动编译一下插件
首先进入YCM的文件夹执行install.py(不支持C语法)
```shell
cd ~/.vim/bundle/YouCompleteMe
python3 install.py
```
这一步如果出现问题，可能需要在执行如下命令
```shell
cd ~/.vim/bundle/YouCompleteMe
git submodule update --init --recursive
```

如果需要支持C语法则需要执行(Ubuntu平台)
```shell
sudo apt install build-essential cmake python3-dev
```
之后进入文件夹执行
```shell
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --clang-completer
```
对于想要支持C/C++语言的人来说，需要将ycm_extra_conf.py文件加入到ycm的文件夹下面
```shell
mv ycm_extra_conf.py  ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py
```
之后就可以使用YCM进行C/C++的代码补全了

**如果使用python后发现没有补全效果，则需要对.vimrc文件进行如下修改：**
将
```vim
let g:ycm_python_binary_path = 'python'
```
改成自己的配置，比如
```vim
let g:ycm_python_binary_path = '/usr/bin/python3'
```

## Oh-my-zsh Configuration
首先需要安装zsh以及一些依赖
```
sudo apt update
sudo apt install -y zsh python-pygments autojump
```
之后在home目录解压zsh.tar.gz

```shell
cd ~
tar xvf ~/MyConfig/zsh.tar.gz
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
