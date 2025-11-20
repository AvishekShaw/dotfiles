#!/usr/bin/env bash
################################################################################
# test.sh - Test dotfiles configuration
#
# This script tests that all configurations load without errors.
#
# Usage:
#   ./scripts/test.sh
#   make test
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$HOME/Code/dotfiles"
TESTS_PASSED=0
TESTS_FAILED=0

print_test() {
    echo -e "${BLUE}→${NC} Testing: $1"
}

test_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
}

test_fail() {
    echo -e "${RED}✗${NC} $1"
    ((TESTS_FAILED++))
}

################################################################################
# Test: Shell Configuration
################################################################################

test_shell() {
    print_test "Shell configuration loads"

    # Test zsh loads
    if zsh -c "source ~/.zshrc" 2>/dev/null; then
        test_pass "zshrc loads without errors"
    else
        test_fail "zshrc has errors"
    fi
}

################################################################################
# Test: Vim Configuration
################################################################################

test_vim() {
    print_test "Vim configuration"

    if ! command -v vim &> /dev/null; then
        test_fail "Vim not installed"
        return
    fi

    # Test vim loads config
    if vim -u ~/.vimrc +qall 2>/dev/null; then
        test_pass "Vim configuration loads"
    else
        test_fail "Vim configuration has errors"
    fi
}

################################################################################
# Test: Neovim Configuration
################################################################################

test_neovim() {
    print_test "Neovim configuration"

    if ! command -v nvim &> /dev/null; then
        test_fail "Neovim not installed"
        return
    fi

    # Test nvim loads config
    if nvim --headless +qall 2>/dev/null; then
        test_pass "Neovim configuration loads"
    else
        test_fail "Neovim configuration has errors"
    fi
}

################################################################################
# Test: Git Configuration
################################################################################

test_git() {
    print_test "Git configuration"

    if ! command -v git &> /dev/null; then
        test_fail "Git not installed"
        return
    fi

    # Test git config is valid
    if git config --list &> /dev/null; then
        test_pass "Git configuration is valid"
    else
        test_fail "Git configuration has errors"
    fi

    # Check for user name and email
    if git config user.name &> /dev/null && git config user.email &> /dev/null; then
        test_pass "Git user name and email configured"
    else
        test_fail "Git user name or email not configured"
    fi
}

################################################################################
# Test: Symlinks
################################################################################

test_symlinks() {
    print_test "Symlinks"

    local all_good=true

    for link in ~/.vimrc ~/.zshrc ~/.gitconfig ~/.tmux.conf; do
        if [[ -L "$link" ]]; then
            if [[ -e "$link" ]]; then
                continue
            else
                test_fail "$(basename $link) is broken symlink"
                all_good=false
            fi
        else
            test_fail "$(basename $link) is not a symlink"
            all_good=false
        fi
    done

    if $all_good; then
        test_pass "All primary symlinks are valid"
    fi
}

################################################################################
# Test: Package Files
################################################################################

test_package_files() {
    print_test "Package files"

    if [[ -f "$DOTFILES_DIR/packages/Brewfile" ]]; then
        test_pass "Brewfile exists"
    else
        test_fail "Brewfile missing"
    fi

    if [[ -f "$DOTFILES_DIR/packages/requirements.txt" ]]; then
        test_pass "requirements.txt exists"
    else
        test_fail "requirements.txt missing"
    fi
}

################################################################################
# Test: Hooks
################################################################################

test_hooks() {
    print_test "Auto-sync hooks"

    if [[ -f "$DOTFILES_DIR/hooks/brew.zsh" ]]; then
        test_pass "Brew hook exists"
    else
        test_fail "Brew hook missing"
    fi

    if [[ -f "$DOTFILES_DIR/hooks/pip.zsh" ]]; then
        test_pass "Pip hook exists"
    else
        test_fail "Pip hook missing"
    fi
}

################################################################################
# Main
################################################################################

main() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              Dotfiles Configuration Tests                     ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"

    test_shell
    test_vim
    test_neovim
    test_git
    test_symlinks
    test_package_files
    test_hooks

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ All tests passed ($TESTS_PASSED/$((TESTS_PASSED + TESTS_FAILED)))${NC}"
        exit 0
    else
        echo -e "${RED}✗ $TESTS_FAILED test(s) failed${NC}"
        echo -e "${GREEN}✓ $TESTS_PASSED test(s) passed${NC}"
        exit 1
    fi
}

main "$@"
