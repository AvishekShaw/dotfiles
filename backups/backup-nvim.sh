#!/bin/bash
# Backup script for Neovim configuration
# Run this after you have a stable, working setup

set -e  # Exit on error

BACKUP_DIR="$HOME/Code/dotfiles/nvim-backups"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="nvim-backup-$DATE"

echo "Creating Neovim backup: $BACKUP_NAME"

# Create backup directory
mkdir -p "$BACKUP_DIR/$BACKUP_NAME"

# Copy init.lua
if [ -f "$HOME/Code/dotfiles/config/nvim/init.lua" ]; then
    cp "$HOME/Code/dotfiles/config/nvim/init.lua" "$BACKUP_DIR/$BACKUP_NAME/"
    echo "✓ Backed up init.lua"
fi

# Copy lazy-lock.json (plugin versions)
if [ -f "$HOME/.local/share/nvim/lazy-lock.json" ]; then
    cp "$HOME/.local/share/nvim/lazy-lock.json" "$BACKUP_DIR/$BACKUP_NAME/"
    echo "✓ Backed up lazy-lock.json (plugin versions)"
fi

# Create system info
cat > "$BACKUP_DIR/$BACKUP_NAME/system-info.txt" << EOF
Backup created: $DATE
Neovim version: $(nvim --version | head -1)
OS: $(uname -s) $(uname -r)
Python: $(python3 --version 2>&1)

Installed tools:
- ripgrep: $(which rg || echo "not installed")
- fd: $(which fd || echo "not installed")
- jupytext: $(which jupytext || echo "not installed")

Python packages:
$(pip3 list | grep -E "(pynvim|jupyter|jupytext|matplotlib)" || echo "None found")
EOF
echo "✓ Created system-info.txt"

# Create archive
cd "$BACKUP_DIR"
tar -czf "$BACKUP_NAME.tar.gz" "$BACKUP_NAME"
rm -rf "$BACKUP_NAME"

echo ""
echo "✓ Backup complete: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
echo ""
echo "To restore this backup:"
echo "  cd $BACKUP_DIR"
echo "  tar -xzf $BACKUP_NAME.tar.gz"
echo "  cp $BACKUP_NAME/init.lua ~/Code/dotfiles/config/nvim/"
echo "  cp $BACKUP_NAME/lazy-lock.json ~/.local/share/nvim/"
echo ""

# Keep only last 5 backups
cd "$BACKUP_DIR"
ls -t nvim-backup-*.tar.gz | tail -n +6 | xargs -r rm
echo "✓ Cleaned old backups (kept last 5)"
