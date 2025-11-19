# Neovim Configuration Dependencies

This file lists all external dependencies required for your Neovim setup.

## System Requirements

- **Neovim**: >= 0.9.0
- **Git**: For lazy.nvim plugin manager
- **Terminal**: Kitty (for image rendering support)

## External Command-line Tools

### Required for Telescope
```bash
# macOS
brew install ripgrep fd

# Why:
# - ripgrep: Fast grep for live_grep
# - fd: Fast file finder for find_files
```

### Required for Molten (Jupyter in Neovim)
```bash
# Python and pynvim
brew install python3
pip3 install pynvim jupyter

# Why:
# - pynvim: Neovim Python client (required by molten-nvim)
# - jupyter: Jupyter kernel for code execution
```

### Required for Jupytext
```bash
pip3 install jupytext

# Why:
# - jupytext: Converts between .py and .ipynb files
```

### Optional but Recommended
```bash
# For better icon support
brew install --cask font-hack-nerd-font

# Then set your terminal to use "Hack Nerd Font"
```

## Neovim Plugin Health Check

Run this inside Neovim to check what's missing:
```vim
:checkhealth
```

## Quick Setup Script (New Machine)

```bash
#!/bin/bash
# Run this on a fresh macOS install

# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install system tools
brew install neovim ripgrep fd python3

# Install Kitty terminal (for image support)
brew install --cask kitty

# Install Python packages
pip3 install pynvim jupyter jupytext matplotlib

# Install Nerd Font
brew install --cask font-hack-nerd-font

# Clone your dotfiles
cd ~/Code
git clone <your-dotfiles-repo> dotfiles

# Link init.lua
mkdir -p ~/.config/nvim
ln -s ~/Code/dotfiles/init.lua ~/.config/nvim/init.lua

# Start Neovim (plugins will auto-install)
nvim
```

## Troubleshooting

### If molten-nvim fails
```bash
# Reinstall pynvim
pip3 uninstall pynvim
pip3 install pynvim

# Then in Neovim:
:UpdateRemotePlugins
```

### If images don't display
- Ensure you're using Kitty terminal
- Check: `echo $TERM` should show `xterm-kitty`

### If Obsidian autocomplete fails
- Ensure nvim-cmp is installed: `:Lazy`
- Check completion sources: `:lua print(vim.inspect(require('cmp').get_config().sources))`

### If Telescope is slow
- Ensure ripgrep is installed: `which rg`
- Ensure fd is installed: `which fd`

## Version Lock File

Your plugin versions are locked in `~/.config/nvim/lazy-lock.json`.

To create/update it:
```vim
:Lazy restore    " Install exact versions from lockfile
:Lazy update     " Update all plugins (be careful!)
```

After a successful update, backup the lockfile:
```bash
cp ~/.local/share/nvim/lazy-lock.json ~/Code/dotfiles/lazy-lock.json
git add lazy-lock.json
git commit -m "Lock plugin versions - $(date +%Y-%m-%d)"
```

## Minimal Fallback Config

If plugins are broken, use this minimal config:

```bash
# Create minimal config
cat > ~/.config/nvim/init.minimal.lua << 'EOF'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = " "
EOF

# Launch with minimal config
nvim -u ~/.config/nvim/init.minimal.lua
```
