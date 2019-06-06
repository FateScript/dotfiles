#### vim config
cp light_vimrc ~/.vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
mv flake8 ~/.flake8

#### YCM config
cd ~/.vim/bundle/YouCompleteMe
python3 install.py
sudo apt install build-essential cmake python3-dev
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --clang-completer
cp ycm_extra_conf.py  ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py
pip3 install --user flake8

### zsh config
sudo apt update
sudo apt install -y zsh python-pygments autojump
cd ~
tar xvf ~/MyConf/zsh.tar.gz
sudo chsh $USER -s /usr/bin/zsh

#### tmux config
sudo apt-get install tmux
cp MyConf/tmux.conf ~/.tmux.conf
echo "Done!"
