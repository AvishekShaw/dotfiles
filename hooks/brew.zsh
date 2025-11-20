#!/usr/bin/env zsh
################################################################################
# brew.zsh - Automatic Brewfile sync hook
#
# This wrapper function automatically updates your Brewfile whenever you
# install, uninstall, or upgrade packages with Homebrew.
#
# Usage: Just use `brew` commands normally:
#   brew install neovim       # Brewfile auto-updates after install
#   brew uninstall ripgrep    # Brewfile auto-updates after uninstall
#
# To disable temporarily:
#   unset -f brew
#   command brew install something
#
# Environment Variables:
#   DOTFILES_AUTO_COMMIT=1    # Auto-commit changes (optional)
################################################################################

brew() {
    local DOTFILES_DIR="$HOME/Code/dotfiles"
    local BREWFILE="$DOTFILES_DIR/packages/Brewfile"

    # Run the actual brew command
    command brew "$@"
    local brew_exit_code=$?

    # Only update Brewfile if the command succeeded and it was an install/uninstall
    if [[ $brew_exit_code -eq 0 ]] && [[ "$1" =~ ^(install|uninstall|remove|tap|untap)$ ]]; then
        echo ""
        echo "📦 Updating Brewfile..."

        # Generate new Brewfile
        if command brew bundle dump --file="$BREWFILE" --force 2>/dev/null; then
            echo "✓ Brewfile updated successfully"

            # Optional: Auto-commit
            if [[ -n "$DOTFILES_AUTO_COMMIT" ]]; then
                (
                    cd "$DOTFILES_DIR"
                    if git add packages/Brewfile 2>/dev/null && git commit -m "Update Brewfile: brew $*" --no-verify 2>/dev/null; then
                        echo "✓ Changes committed to git"
                    fi
                )
            else
                echo "ℹ️  Don't forget to commit: cd $DOTFILES_DIR && git add packages/Brewfile && git commit"
            fi
        else
            echo "⚠️  Failed to update Brewfile"
        fi
    fi

    return $brew_exit_code
}
