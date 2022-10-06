#!/bin/bash

#if [[ -f ~/.zshrc ]]; then
#echo "zshrc exists"
#fi
if [[ -f ~/.zshrc ]]; then
	mv ~/.zshrc ~/.zshrc.old && echo \
		".zshrc moved to .zshrc.old"
fi

ln -sf ~/dotfiles/zsh/zshrc ~/.zshrc && echo \
	"soft link to zshrc created"                            # create symlink to zshrc

