# First the business of the shell. 
# ---------------------------------
chsh -s /usr/bin/zsh && echo "zsh made the default shell"		# First change the default shell to zsh
#sh -c "$(curl -fsSL https://raw.githubusercontent.com\
#/ohmyzsh/ohmyzsh/master/tools/install.sh)" && echo \
#"oh-my-zsh installed"							# install oh-my-zsh
ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc && echo "soft \
link to zshrc created"  

# check jose's file for inspiration
#ln -sf ~/.dotfiles/zsh/.p10k.zsh ~/.p10k.zsh && echo\
#"soft link to .p10k.zsh created"
#--------------------------------------

ln -sf ~/.dotfiles/vim/.vimrc ~/.vimrc && echo "soft \
link to vimrc created"						 	# create link to the vimrc
ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig && echo "soft \
link to gitconfig created"  						# create link to the gitconfig
ln -sf ~/.dotfiles/.matplotlibrc ~/.config/matplotlib/\
.matplotlibrc && echo "soft link to matplotlibrc created" 		# create link to matplotlibrc
