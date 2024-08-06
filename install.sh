#!/bin/bash

ln -sf $HOME/Code/dotfiles/.vimrc ~/.vimrc && echo "soft link to vimrc created"						 	
ln -sf $HOME/Code/dotfiles/gitconfig ~/.gitconfig && echo "soft link to gitconfig created"  						
# ln -sf $HOME/Code/dotfiles/matplotlibrc ~/.config/matplotlib/.matplotlibrc && echo "soft link to matplotlibrc created" 		


brew install zsh-syntax-highlighting && echo "source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc

