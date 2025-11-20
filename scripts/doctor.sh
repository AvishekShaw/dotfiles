#!/usr/bin/env bash
################################################################################
# doctor.sh - Dotfiles Health Check
#
# This script performs a comprehensive health check of your dotfiles setup,
# verifying symlinks, package synchronization, and overall system state.
#
# Usage:
#   ./scripts/doctor.sh
#   make doctor
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_DIR="$HOME/Code/dotfiles"
ERRORS=0
WARNINGS=0

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

check_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

################################################################################
# Check 1: Symlinks
################################################################################

check_symlinks() {
    print_header "Symlink Status"

    local symlinks=(
        "$HOME/.vimrc:$DOTFILES_DIR/home/vimrc"
        "$HOME/.zshrc:$DOTFILES_DIR/shell/zshrc"
        "$HOME/.gitconfig:$DOTFILES_DIR/home/gitconfig"
        "$HOME/.tmux.conf:$DOTFILES_DIR/home/tmux.conf"
        "$HOME/.config/nvim/init.lua:$DOTFILES_DIR/config/nvim/init.lua"
        "$HOME/.newsboat/config:$DOTFILES_DIR/config/newsboat/config"
        "$HOME/.newsboat/urls:$DOTFILES_DIR/config/newsboat/urls"
    )

    for entry in "${symlinks[@]}"; do
        local link="${entry%%:*}"
        local expected_target="${entry#*:}"

        if [[ -L "$link" ]]; then
            local actual_target=$(readlink "$link")
            if [[ "$actual_target" == "$expected_target" ]]; then
                check_pass "$(basename "$link") → dotfiles"
            else
                check_fail "$(basename "$link") points to wrong location"
                echo "    Expected: $expected_target"
                echo "    Actual:   $actual_target"
            fi
        elif [[ -e "$link" ]]; then
            check_warn "$(basename "$link") exists but is not a symlink"
        else
            check_warn "$(basename "$link") does not exist"
        fi
    done
}

################################################################################
# Check 2: Homebrew Packages
################################################################################

check_brew_packages() {
    print_header "Homebrew Package Sync"

    if ! command -v brew &> /dev/null; then
        check_warn "Homebrew not installed"
        return
    fi

    check_info "Installed: $(brew list --formula | wc -l | tr -d ' ') formulae, $(brew list --cask | wc -l | tr -d ' ') casks"

    if [[ ! -f "$DOTFILES_DIR/packages/Brewfile" ]]; then
        check_fail "Brewfile not found"
        return
    fi

    # Count packages in Brewfile
    local brewfile_formulae=$(grep -c "^brew " "$DOTFILES_DIR/packages/Brewfile" 2>/dev/null || echo 0)
    local brewfile_casks=$(grep -c "^cask " "$DOTFILES_DIR/packages/Brewfile" 2>/dev/null || echo 0)
    check_info "In Brewfile: $brewfile_formulae formulae, $brewfile_casks casks"

    # Check if there are packages not in Brewfile
    local temp_brewfile=$(mktemp)
    brew bundle dump --file="$temp_brewfile" --force 2>/dev/null

    if diff -q "$DOTFILES_DIR/packages/Brewfile" "$temp_brewfile" > /dev/null 2>&1; then
        check_pass "Brewfile is in sync"
    else
        check_warn "Brewfile is out of sync"
        echo ""
        echo "  Differences:"
        diff "$DOTFILES_DIR/packages/Brewfile" "$temp_brewfile" 2>/dev/null | grep "^[<>]" | head -10 | sed 's/^/    /'
        echo ""
        echo "  Run: ${BLUE}./scripts/update.sh${NC} or ${BLUE}make update${NC} to sync"
    fi

    rm -f "$temp_brewfile"
}

################################################################################
# Check 3: Python Packages
################################################################################

check_pip_packages() {
    print_header "Python Package Sync"

    if ! command -v pip3 &> /dev/null; then
        check_warn "pip3 not installed"
        return
    fi

    local installed_count=$(pip3 list --format=freeze 2>/dev/null | wc -l | tr -d ' ')
    check_info "Installed: $installed_count packages"

    if [[ ! -f "$DOTFILES_DIR/packages/requirements.txt" ]]; then
        check_fail "requirements.txt not found"
        return
    fi

    local requirements_count=$(wc -l < "$DOTFILES_DIR/packages/requirements.txt" | tr -d ' ')
    check_info "In requirements.txt: $requirements_count packages"

    # Check if requirements.txt is up to date
    local temp_requirements=$(mktemp)
    pip3 freeze > "$temp_requirements" 2>/dev/null

    if diff -q "$DOTFILES_DIR/packages/requirements.txt" "$temp_requirements" > /dev/null 2>&1; then
        check_pass "requirements.txt is in sync"
    else
        check_warn "requirements.txt is out of sync"
        echo ""
        echo "  Differences (first 10):"
        diff "$DOTFILES_DIR/packages/requirements.txt" "$temp_requirements" 2>/dev/null | grep "^[<>]" | head -10 | sed 's/^/    /'
        echo ""
        echo "  Run: ${BLUE}./scripts/update.sh${NC} or ${BLUE}make update${NC} to sync"
    fi

    rm -f "$temp_requirements"
}

################################################################################
# Check 4: Git Status
################################################################################

check_git_status() {
    print_header "Git Repository Status"

    if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
        check_fail "Not a git repository"
        return
    fi

    cd "$DOTFILES_DIR"

    # Check if repo is clean
    if git diff --quiet && git diff --cached --quiet; then
        check_pass "No uncommitted changes"
    else
        check_warn "Uncommitted changes detected"
        git status --short | sed 's/^/    /'
    fi

    # Check if we're ahead of remote
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ -n "$branch" ]]; then
        check_info "Current branch: $branch"

        local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
        if [[ $ahead -gt 0 ]]; then
            check_warn "$ahead commit(s) not pushed"
        else
            check_pass "In sync with remote"
        fi
    fi
}

################################################################################
# Check 5: Essential Tools
################################################################################

check_tools() {
    print_header "Essential Tools"

    local tools=(
        "zsh:Zsh shell"
        "vim:Vim editor"
        "nvim:Neovim editor"
        "tmux:Terminal multiplexer"
        "git:Version control"
        "brew:Package manager"
        "newsboat:RSS reader"
    )

    for entry in "${tools[@]}"; do
        local tool="${entry%%:*}"
        local description="${entry#*:}"

        if command -v "$tool" &> /dev/null; then
            local version=$(eval "$tool --version 2>&1 | head -1")
            check_pass "$description ($tool)"
        else
            check_warn "$description ($tool) not installed"
        fi
    done
}

################################################################################
# Check 6: Shell Configuration
################################################################################

check_shell_config() {
    print_header "Shell Configuration"

    # Check if hooks are loaded
    if [[ -f "$DOTFILES_DIR/hooks/brew.zsh" ]]; then
        check_pass "Brew hook exists"
    else
        check_fail "Brew hook missing"
    fi

    if [[ -f "$DOTFILES_DIR/hooks/pip.zsh" ]]; then
        check_pass "Pip hook exists"
    else
        check_fail "Pip hook missing"
    fi

    # Check if current shell is zsh
    if [[ "$SHELL" == "$(which zsh)" ]]; then
        check_pass "Zsh is default shell"
    else
        check_warn "Default shell is not zsh: $SHELL"
    fi

    # Check Oh My Zsh
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        check_pass "Oh My Zsh installed"
    else
        check_warn "Oh My Zsh not installed"
    fi
}

################################################################################
# Check 7: Neovim Setup
################################################################################

check_neovim() {
    print_header "Neovim Configuration"

    if ! command -v nvim &> /dev/null; then
        check_warn "Neovim not installed"
        return
    fi

    # Check if init.lua exists and is symlinked
    if [[ -L "$HOME/.config/nvim/init.lua" ]]; then
        check_pass "init.lua is symlinked"
    else
        check_warn "init.lua is not symlinked"
    fi

    # Check if lazy-lock.json exists (plugin lockfile)
    if [[ -f "$HOME/.config/nvim/lazy-lock.json" ]]; then
        check_pass "Plugin lockfile exists"
    else
        check_warn "Plugin lockfile missing (run Neovim to generate)"
    fi
}

################################################################################
# Summary
################################################################################

print_summary() {
    print_header "Summary"

    if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
        echo -e "${GREEN}🎉 Perfect! Everything looks good.${NC}"
    elif [[ $ERRORS -eq 0 ]]; then
        echo -e "${YELLOW}✓ No critical issues found${NC}"
        echo -e "${YELLOW}⚠ $WARNINGS warning(s) - see above for details${NC}"
    else
        echo -e "${RED}✗ $ERRORS error(s) found${NC}"
        echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
        echo ""
        echo "Run ${BLUE}./scripts/bootstrap.sh${NC} to fix configuration issues"
    fi

    echo ""
}

################################################################################
# Main Execution
################################################################################

main() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              Dotfiles Health Check                           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    check_symlinks
    check_brew_packages
    check_pip_packages
    check_git_status
    check_tools
    check_shell_config
    check_neovim

    print_summary

    # Exit with error if there are errors
    [[ $ERRORS -eq 0 ]] && exit 0 || exit 1
}

main "$@"
