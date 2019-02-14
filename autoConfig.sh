#### vim config
mv vimrc ~/.vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

#### YCM config
cd ~/.vim/bundle/YouCompleteMe
python3 install.py
sudo apt install build-essential cmake python3-dev
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --clang-completer
mv ycm_extra_conf.py  ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py

### zsh config
sudo apt update
sudo apt install -y zsh python-pygments autojump
cd ~
tar xvf ~/MyConf/zsh.tar.gz
sudo chsh $USER -s /usr/bin/zsh

#### tmux config
sudo apt-get install tmux
mv MyConf/tmux.conf ~/.tmux.conf
echo "Done!"
