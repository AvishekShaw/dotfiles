# Dotfiles

Personal macOS configuration with automatic package syncing, health monitoring, and multi-machine support.

## Features

- ✅ **Auto-sync** - Automatically updates Brewfile/requirements.txt when installing packages
- ✅ **Health checks** - Monitor dotfiles status with `make doctor`
- ✅ **Testing** - Verify configurations load properly
- ✅ **Multi-machine** - Support different configs per machine
- ✅ **Organized** - Clean directory structure for scalability

## Quick Start

### Fresh Mac Setup

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/Code/dotfiles
cd ~/Code/dotfiles

# Preview installation
./scripts/bootstrap.sh --dry-run

# Install everything
./scripts/bootstrap.sh

# Add your API keys
vim ~/.env.local

# Restart shell
source ~/.zshrc
```

### Existing Setup

```bash
# Update package lists
make update

# Check health
make doctor

# Test configurations
make test
```

## Directory Structure

```
dotfiles/
├── shell/          # Shell configs (zshrc, env, alias, functions)
├── home/           # Dotfiles (vimrc, tmux.conf, gitconfig)
├── config/         # XDG configs (nvim/, newsboat/)
├── packages/       # Brewfile, requirements.txt
├── scripts/        # Automation scripts
├── hooks/          # Auto-sync hooks
├── backups/        # Backup scripts
├── templates/      # Configuration templates
└── machines/       # Machine-specific overrides
```

## Package Management

### Automatic Sync (Already Enabled!)

When you install packages, dotfiles auto-update:

```bash
brew install htop
# 📦 Updating Brewfile...
# ✓ Brewfile updated successfully

pip3 install requests
# 🐍 Updating requirements.txt...
# ✓ requirements.txt updated successfully
```

### Manual Update

```bash
make update  # Update both Brewfile and requirements.txt
```

### Auto-Commit (Optional)

```bash
# Add to ~/.env.local
export DOTFILES_AUTO_COMMIT=1

# Now installs will auto-commit too
brew install tree
# ✓ Brewfile updated
# ✓ Changes committed to git
```

## Commands

```bash
make help       # Show all commands
make install    # Full installation
make update     # Update package lists
make doctor     # Health check
make test       # Test configurations
make status     # Quick status
make clean      # Remove backups
make macos      # Apply macOS preferences
```

## Configuration

### Shell Configuration

Shell configs are modular:
- **`shell/env`** - Environment variables, PATH, tool initialization
- **`shell/alias`** - Command aliases
- **`shell/functions`** - Custom shell functions
- **`shell/zshrc`** - Main zsh config (sources above files)

### Secrets Management

**Never commit secrets!**

```bash
# Create ~/.env.local (NOT tracked in git)
cp templates/env.local.template ~/.env.local

# Add your secrets
vim ~/.env.local
```

### Multi-Machine Support

Create machine-specific configs:

```bash
# Create config for this machine
hostname -s  # Shows your hostname
touch machines/$(hostname -s).zsh

# Add machine-specific settings
echo 'git config --global user.email "work@company.com"' >> machines/$(hostname -s).zsh
```

See `machines/README.md` for details.

## Neovim Setup

### Requirements

- Neovim >= 0.9.0
- Git
- Terminal with true color support (iTerm2, Kitty, etc.)

### External Tools

```bash
# Install dependencies
brew install neovim ripgrep fd python3

# Install Python support
pip3 install pynvim jupyter jupytext

# Install Nerd Font
brew install --cask font-hack-nerd-font
```

### First Launch

Plugins install automatically on first launch:

```bash
nvim
# Plugins will install automatically via lazy.nvim
```

### Plugin Management

- **Plugin manager**: lazy.nvim
- **Version lock**: `~/.config/nvim/lazy-lock.json`

```bash
# Update plugins
nvim
:Lazy sync

# Check health
:checkhealth
```

### Backup & Restore

```bash
# Backup Neovim config
./backups/backup-nvim.sh

# Backups stored in nvim-backups/ with version info
```

## Health Monitoring

### Run Health Check

```bash
make doctor
```

Checks:
- ✓ Symlinks are valid
- ✓ Brewfile in sync with installed packages
- ✓ requirements.txt in sync with pip
- ✓ Git repository status
- ✓ Essential tools installed
- ✓ Shell configuration loaded
- ✓ Hooks are active

### Run Tests

```bash
make test
```

Tests:
- Shell configuration loads
- Vim configuration loads
- Neovim configuration loads
- Git configuration valid
- Symlinks work
- Package files exist
- Hooks installed

## Maintenance

### Keep Dotfiles Updated

```bash
# When you install packages, they auto-update
brew install wget
pip3 install pandas

# Just commit when ready
git add packages/
git commit -m "Update packages"
git push
```

### Sync Changes

```bash
# Pull latest from another machine
git pull

# Reinstall if needed
./scripts/bootstrap.sh
```

### Restore from Backup

```bash
# List available backups
./scripts/restore.sh

# Restore specific backup
./scripts/restore.sh ~/.dotfiles_backup_20250120_143000
```

## Tracked Configurations

### Shell
- Zsh configuration with Oh My Zsh
- Custom aliases, functions, environment variables
- Tool initialization (rbenv, nvm, etc.)

### Editors
- Vim with vim-plug
- Neovim with lazy.nvim (comprehensive config)
- Git configuration

### Terminal
- Tmux configuration
- Newsboat RSS reader

### Packages
- Homebrew packages (29 formulae + 8 casks)
- Python packages (48 packages)

## macOS System Preferences

Apply opinionated macOS settings:

```bash
# Preview changes
./scripts/macos-defaults.sh --dry-run

# Apply settings
./scripts/macos-defaults.sh
```

Configures:
- Dock, Finder, keyboard, trackpad
- Screenshots, screen saver
- Safari, Terminal, Activity Monitor
- And more...

## Troubleshooting

### Symlinks Broken

```bash
./scripts/bootstrap.sh  # Recreate symlinks
```

### Hooks Not Working

```bash
source ~/.zshrc  # Reload shell

# Verify hooks loaded
type brew  # Should show: "brew is a shell function"
```

### Packages Out of Sync

```bash
make update  # Force update
```

### Configuration Errors

```bash
make test    # Test configurations
make doctor  # Full health check
```

## Tips

- Use `make help` to see all commands
- Run `make doctor` regularly to catch issues
- Enable `DOTFILES_AUTO_COMMIT=1` for fully automatic syncing
- Create machine-specific configs in `machines/` for work vs personal
- Keep secrets in `~/.env.local` (never commit!)

## Resources

- [Homebrew](https://brew.sh/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Neovim](https://neovim.io/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)

---

**Made with [Claude Code](https://claude.com/claude-code)**
