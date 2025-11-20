# Dotfiles Makefile
# Convenient commands for managing your dotfiles

.PHONY: help install update sync doctor test clean

# Default target - show help
help:
	@echo "Dotfiles Management Commands"
	@echo "============================"
	@echo ""
	@echo "  make install     - Full installation (bootstrap)"
	@echo "  make update      - Update Brewfile and requirements.txt"
	@echo "  make sync        - Pull from git and reinstall"
	@echo "  make doctor      - Run health check"
	@echo "  make test        - Test configuration (coming soon)"
	@echo "  make clean       - Remove backup files"
	@echo ""

# Full installation from scratch
install:
	@echo "🚀 Running full installation..."
	./scripts/bootstrap.sh

# Dry-run installation (preview changes)
install-dry:
	@echo "🔍 Running installation preview..."
	./scripts/bootstrap.sh --dry-run

# Update package lists (Brewfile, requirements.txt)
update:
	@echo "📦 Updating package lists..."
	./scripts/update.sh

# Pull latest changes and sync
sync:
	@echo "🔄 Syncing with remote..."
	git pull
	./scripts/bootstrap.sh

# Run health check
doctor:
	@echo "🏥 Running health check..."
	./scripts/doctor.sh

# Test configuration (placeholder for future)
test:
	@echo "🧪 Testing configuration..."
	@echo "Running basic checks..."
	@zsh -c "source ~/.zshrc && echo '✓ .zshrc loads successfully'"
	@command -v brew > /dev/null && echo "✓ Homebrew installed" || echo "✗ Homebrew not found"
	@command -v nvim > /dev/null && echo "✓ Neovim installed" || echo "✗ Neovim not found"
	@echo "For comprehensive checks, run: make doctor"

# Clean up backup files
clean:
	@echo "🧹 Cleaning up backup files..."
	@rm -f ~/.vimrc.backup_* ~/.zshrc.backup_* ~/.newsboat/*.backup_* 2>/dev/null || true
	@echo "✓ Cleanup complete"

# Quick status check
status:
	@echo "📊 Dotfiles Status"
	@echo "=================="
	@echo ""
	@echo "Git status:"
	@git status --short
	@echo ""
	@echo "Installed packages:"
	@command -v brew > /dev/null && echo "  Homebrew: $$(brew list --formula | wc -l | tr -d ' ') formulae, $$(brew list --cask | wc -l | tr -d ' ') casks" || echo "  Homebrew: not installed"
	@command -v pip3 > /dev/null && echo "  Python: $$(pip3 list | wc -l | tr -d ' ') packages" || echo "  Python: not installed"
	@echo ""
	@echo "Package tracking:"
	@test -f packages/Brewfile && echo "  Brewfile: $$(grep -c '^brew' packages/Brewfile) packages, $$(grep -c '^cask' packages/Brewfile) casks" || echo "  Brewfile: not found"
	@test -f packages/requirements.txt && echo "  requirements.txt: $$(wc -l < packages/requirements.txt | tr -d ' ') packages" || echo "  requirements.txt: not found"

# Apply macOS system preferences
macos:
	@echo "🍎 Configuring macOS preferences..."
	./scripts/macos-defaults.sh

# Apply macOS preferences (dry run)
macos-dry:
	@echo "🔍 Previewing macOS preferences..."
	./scripts/macos-defaults.sh --dry-run

# Commit current changes
commit:
	@echo "💾 Committing changes..."
	@git add .
	@git status
	@echo ""
	@read -p "Commit message: " msg; \
	git commit -m "$$msg"

# Push to remote
push:
	@echo "📤 Pushing to remote..."
	git push
