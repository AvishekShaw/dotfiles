#!/usr/bin/env zsh
################################################################################
# pip.zsh - Automatic requirements.txt sync hook
#
# This wrapper function automatically updates your requirements.txt whenever
# you install or uninstall Python packages with pip3.
#
# Usage: Just use `pip3` commands normally:
#   pip3 install numpy         # requirements.txt auto-updates
#   pip3 uninstall requests    # requirements.txt auto-updates
#
# To disable temporarily:
#   unset -f pip3
#   command pip3 install something
#
# Environment Variables:
#   DOTFILES_AUTO_COMMIT=1    # Auto-commit changes (optional)
################################################################################

pip3() {
    local DOTFILES_DIR="$HOME/Code/dotfiles"
    local REQUIREMENTS_FILE="$DOTFILES_DIR/packages/requirements.txt"

    # Run the actual pip3 command
    command pip3 "$@"
    local pip_exit_code=$?

    # Only update requirements.txt if the command succeeded and it was an install/uninstall
    if [[ $pip_exit_code -eq 0 ]] && [[ "$1" =~ ^(install|uninstall)$ ]]; then
        echo ""
        echo "🐍 Updating requirements.txt..."

        # Generate new requirements.txt (excluding macOS system packages)
        if command pip3 list --format=freeze --exclude altgraph --exclude future --exclude macholib --exclude six > "$REQUIREMENTS_FILE" 2>/dev/null; then
            local pkg_count=$(wc -l < "$REQUIREMENTS_FILE" | tr -d ' ')
            echo "✓ requirements.txt updated successfully ($pkg_count packages)"

            # Optional: Auto-commit
            if [[ -n "$DOTFILES_AUTO_COMMIT" ]]; then
                (
                    cd "$DOTFILES_DIR"
                    if git add packages/requirements.txt 2>/dev/null && git commit -m "Update requirements.txt: pip3 $*" --no-verify 2>/dev/null; then
                        echo "✓ Changes committed to git"
                    fi
                )
            else
                echo "ℹ️  Don't forget to commit: cd $DOTFILES_DIR && git add packages/requirements.txt && git commit"
            fi
        else
            echo "⚠️  Failed to update requirements.txt"
        fi
    fi

    return $pip_exit_code
}
