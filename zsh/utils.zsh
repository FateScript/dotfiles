
autoload -U compinit && compinit -u

# compdef
compdef _src src
compdef _conf conf
compdef _act_venv act_venv rm_venv
compdef _bluetooth_device bluetooth_conn bluetooth_disconn
compdef _sftp_upload sftp_upload

compdef _git ga=git-add
compdef _git gc=git-commit
compdef _git gp=git-push
compdef _git gpp=git-pull
compdef _git gf=git-fetch
compdef _git gck=git-checkout
compdef _git gb=git-branch
compdef _git gr=git-remote

# specific filetype
_pic() { _files -g '*.(jpg|png|bmp|gif|ppm|pbm|jpeg|xcf|ico)(-.)' }
compdef _pic gimp
compdef _pic imgcat
compdef _pic feh
compdef _pip pip2
compdef _pip pip3
