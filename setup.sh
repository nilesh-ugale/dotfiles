echo ls -s $(pwd)/.vimrc ~/.vimrc
echo ls -s $(pwd)/.tmux.conf ~/.tmux.conf
sudo apt update
sudo apt install curl
curl -fLo $(echo "${HOME}/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim")
vim +'PlugInstall --sync' +qa
exec $(echo "${HOME}/.vim/plug/fzf/install --key-bindings --completion --update-rc")

source $(echo "${HOME}/.bashrc")
