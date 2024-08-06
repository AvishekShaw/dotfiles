#!/bin/bash

echo "First time setup"
echo "###############"

# install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && echo "vim-plug installed"
# if .vimrc is present, move it to .vimrc_old
if [ -f ~/.vimrc ]; then
    mv ~/.vimrc ~/.vimrc_old && echo "old .vimrc moved to .vimrc_old"
fi

# create soft links for vimrc
ln -sf $HOME/Code/dotfiles/.vimrc ~/.vimrc && echo "soft link to vimrc created"						 	

# if .gitconfig is present, move it to .gitconfig_old
if [ -f ~/.gitconfig ]; then
    mv ~/.gitconfig ~/.gitconfig_old && echo "old .gitconfig moved to .gitconfig_old"
fi

# create soft links for gitconfig
ln -sf $HOME/Code/dotfiles/gitconfig ~/.gitconfig && echo "soft link to gitconfig created"  						

# ln -sf $HOME/Code/dotfiles/matplotlibrc ~/.config/matplotlib/.matplotlibrc && echo "soft link to matplotlibrc created" 		

# install zsh-syntax_hightlighting
brew install zsh-syntax-highlighting && echo "source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc \
&& echo "zsh-syntax-highlighting installed"
# install zsh-autosuggestions
brew install zsh-autosuggestions && echo "source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc \
&& echo "zsh-autosuggestions installed"

