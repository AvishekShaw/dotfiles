#!/usr/bin/env bash

################################################################################
# update.sh - Update dotfiles package lists from current system
#
# This script regenerates Brewfile and requirements.txt from your current
# system state, making it easy to keep your dotfiles in sync with what you
# have installed.
#
# Usage:
#   ./update.sh              # Update all package lists
#   ./update.sh --brew       # Update only Brewfile
#   ./update.sh --pip        # Update only requirements.txt
################################################################################

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_DIR="$HOME/Code/dotfiles"
UPDATE_BREW=true
UPDATE_PIP=true

# Parse arguments
if [ $# -gt 0 ]; then
    UPDATE_BREW=false
    UPDATE_PIP=false

    for arg in "$@"; do
        case $arg in
            --brew)
                UPDATE_BREW=true
                shift
                ;;
            --pip)
                UPDATE_PIP=true
                shift
                ;;
            --help|-h)
                echo "Usage: ./update.sh [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --brew    Update only Brewfile"
                echo "  --pip     Update only requirements.txt"
                echo "  --help    Show this help message"
                echo ""
                echo "If no options provided, updates both."
                exit 0
                ;;
        esac
    done
fi

print_header() {
    echo -e "\n${BLUE}===================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

update_brewfile() {
    print_header "Updating Brewfile"

    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}⚠${NC} Homebrew not installed, skipping Brewfile update"
        return 0
    fi

    print_info "Generating Brewfile from current system..."

    # Backup existing Brewfile
    if [ -f "$DOTFILES_DIR/packages/Brewfile" ]; then
        cp "$DOTFILES_DIR/packages/Brewfile" "$DOTFILES_DIR/packages/Brewfile.backup"
        print_info "Backed up existing Brewfile"
    fi

    # Generate new Brewfile
    cd "$DOTFILES_DIR"
    brew bundle dump --file=packages/Brewfile --force

    # Count packages
    local brew_count=$(grep -c "^brew " packages/Brewfile || echo 0)
    local cask_count=$(grep -c "^cask " packages/Brewfile || echo 0)

    print_success "Brewfile updated: $brew_count packages, $cask_count casks"

    # Show diff if there are changes
    if [ -f "$DOTFILES_DIR/packages/Brewfile.backup" ]; then
        if ! diff -q packages/Brewfile packages/Brewfile.backup > /dev/null 2>&1; then
            print_info "Changes detected:"
            echo ""
            diff packages/Brewfile.backup packages/Brewfile | grep "^[<>]" | head -20
            echo ""
            rm "$DOTFILES_DIR/packages/Brewfile.backup"
        else
            print_info "No changes from previous Brewfile"
            rm "$DOTFILES_DIR/packages/Brewfile.backup"
        fi
    fi
}

update_requirements() {
    print_header "Updating requirements.txt"

    if ! command -v pip3 &> /dev/null; then
        echo -e "${YELLOW}⚠${NC} pip3 not installed, skipping requirements.txt update"
        return 0
    fi

    print_info "Generating requirements.txt from current system..."

    # Backup existing requirements.txt
    if [ -f "$DOTFILES_DIR/packages/requirements.txt" ]; then
        cp "$DOTFILES_DIR/packages/requirements.txt" "$DOTFILES_DIR/packages/requirements.txt.backup"
        print_info "Backed up existing requirements.txt"
    fi

    # Generate new requirements.txt (excluding macOS system packages)
    pip3 list --format=freeze --exclude altgraph --exclude future --exclude macholib --exclude six > "$DOTFILES_DIR/packages/requirements.txt"

    # Count packages
    local pkg_count=$(wc -l < "$DOTFILES_DIR/packages/requirements.txt" | tr -d ' ')

    print_success "requirements.txt updated: $pkg_count packages"

    # Show diff if there are changes
    if [ -f "$DOTFILES_DIR/packages/requirements.txt.backup" ]; then
        if ! diff -q packages/requirements.txt packages/requirements.txt.backup > /dev/null 2>&1; then
            print_info "Changes detected:"
            echo ""
            diff packages/requirements.txt.backup packages/requirements.txt | grep "^[<>]" | head -20
            echo ""
            rm "$DOTFILES_DIR/packages/requirements.txt.backup"
        else
            print_info "No changes from previous requirements.txt"
            rm "$DOTFILES_DIR/packages/requirements.txt.backup"
        fi
    fi
}

show_git_status() {
    print_header "Git Status"

    cd "$DOTFILES_DIR"

    if git diff --quiet && git diff --cached --quiet; then
        print_info "No changes to commit"
    else
        print_info "Changed files:"
        git status --short
        echo ""
        print_info "Review changes with: git diff"
        print_info "Commit changes with: git add . && git commit -m 'Update package lists'"
    fi
}

main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                  Dotfiles Update Script                          ║"
    echo "║                                                                  ║"
    echo "║  Updates package lists from your current system                 ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"

    # Verify we're in a git repo
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        echo -e "${YELLOW}⚠${NC} Not a git repository: $DOTFILES_DIR"
        echo "This script should be run from a dotfiles git repository"
        exit 1
    fi

    # Run updates
    if [ "$UPDATE_BREW" = true ]; then
        update_brewfile
    fi

    if [ "$UPDATE_PIP" = true ]; then
        update_requirements
    fi

    show_git_status

    print_header "Update Complete"
    echo -e "${GREEN}✓${NC} Package lists have been updated"
    echo ""
}

main "$@"
