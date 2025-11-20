#!/usr/bin/env bash

################################################################################
# bootstrap.sh - Comprehensive dotfiles installation script
#
# This script sets up a new Mac with all configurations, packages, and tools
# from this dotfiles repository. Safe to run multiple times (idempotent).
#
# Usage:
#   ./bootstrap.sh           # Full installation
#   ./bootstrap.sh --dry-run # Preview changes without making them
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$HOME/Code/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            echo -e "${YELLOW}🔍 DRY RUN MODE - No changes will be made${NC}\n"
            shift
            ;;
    esac
done

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${BLUE}===================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Execute command (or skip if dry run)
execute() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would execute: $*"
        return 0
    else
        eval "$@"
    fi
}

# Create backup of existing file
backup_file() {
    local file="$1"
    if [ -f "$file" ] || [ -L "$file" ]; then
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$BACKUP_DIR"
            cp -P "$file" "$BACKUP_DIR/$(basename "$file")"
            print_info "Backed up: $file → $BACKUP_DIR"
        else
            print_info "Would backup: $file"
        fi
    fi
}

# Create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"

    if [ -L "$target" ]; then
        local current_source=$(readlink "$target")
        if [ "$current_source" = "$source" ]; then
            print_info "Symlink already exists: $target → $source"
            return 0
        else
            print_warning "Symlink exists but points elsewhere: $target → $current_source"
            backup_file "$target"
            execute "rm \"$target\""
        fi
    elif [ -e "$target" ]; then
        print_warning "File exists: $target"
        backup_file "$target"
        execute "rm \"$target\""
    fi

    execute "ln -sf \"$source\" \"$target\""
    print_success "Created symlink: $target → $source"
}

################################################################################
# Installation Steps
################################################################################

install_homebrew() {
    print_header "Step 1: Homebrew Installation"

    if command -v brew &> /dev/null; then
        print_success "Homebrew already installed: $(brew --version | head -n1)"
    else
        print_info "Installing Homebrew..."
        if [ "$DRY_RUN" = false ]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            # Add Homebrew to PATH for Apple Silicon Macs
            if [ -d "/opt/homebrew/bin" ]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
            print_success "Homebrew installed successfully"
        else
            print_info "Would install Homebrew"
        fi
    fi
}

install_brew_packages() {
    print_header "Step 2: Installing Homebrew Packages"

    if [ ! -f "$DOTFILES_DIR/packages/Brewfile" ]; then
        print_error "Brewfile not found: $DOTFILES_DIR/packages/Brewfile"
        return 1
    fi

    print_info "Installing from Brewfile..."
    if [ "$DRY_RUN" = false ]; then
        cd "$DOTFILES_DIR"
        brew bundle install --file=packages/Brewfile
        print_success "Homebrew packages installed"
    else
        print_info "Would run: brew bundle install --file=$DOTFILES_DIR/packages/Brewfile"
        print_info "Packages that would be installed:"
        cat "$DOTFILES_DIR/packages/Brewfile" | grep -E "^(brew|cask)" | sed 's/^/  /'
    fi
}

install_python_packages() {
    print_header "Step 3: Installing Python Packages"

    if [ ! -f "$DOTFILES_DIR/packages/requirements.txt" ]; then
        print_warning "requirements.txt not found, skipping Python packages"
        return 0
    fi

    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 not found. Please install Python 3 first."
        return 1
    fi

    print_info "Installing Python packages from requirements.txt..."
    if [ "$DRY_RUN" = false ]; then
        pip3 install -r "$DOTFILES_DIR/packages/requirements.txt"
        print_success "Python packages installed"
    else
        print_info "Would run: pip3 install -r $DOTFILES_DIR/packages/requirements.txt"
        print_info "Packages that would be installed:"
        head -10 "$DOTFILES_DIR/packages/requirements.txt" | sed 's/^/  /'
        local count=$(wc -l < "$DOTFILES_DIR/packages/requirements.txt")
        print_info "  ... and $(($count - 10)) more packages"
    fi
}

install_oh_my_zsh() {
    print_header "Step 4: Installing Oh My Zsh"

    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh already installed"
    else
        print_info "Installing Oh My Zsh..."
        if [ "$DRY_RUN" = false ]; then
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            print_success "Oh My Zsh installed"
        else
            print_info "Would install Oh My Zsh"
        fi
    fi
}

setup_symlinks() {
    print_header "Step 5: Creating Symlinks"

    # Vim
    create_symlink "$DOTFILES_DIR/home/vimrc" "$HOME/.vimrc"

    # Git
    create_symlink "$DOTFILES_DIR/home/gitconfig" "$HOME/.gitconfig"

    # Tmux
    create_symlink "$DOTFILES_DIR/home/tmux.conf" "$HOME/.tmux.conf"

    # Zsh
    create_symlink "$DOTFILES_DIR/shell/zshrc" "$HOME/.zshrc"

    # Neovim
    print_info "Setting up Neovim configuration..."
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$HOME/.config/nvim"
    else
        print_info "Would create: $HOME/.config/nvim"
    fi
    create_symlink "$DOTFILES_DIR/config/nvim/init.lua" "$HOME/.config/nvim/init.lua"

    # Newsboat
    print_info "Setting up Newsboat configuration..."
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$HOME/.newsboat"
    else
        print_info "Would create: $HOME/.newsboat"
    fi
    create_symlink "$DOTFILES_DIR/config/newsboat/config" "$HOME/.newsboat/config"
    create_symlink "$DOTFILES_DIR/config/newsboat/urls" "$HOME/.newsboat/urls"
}

install_vim_plugins() {
    print_header "Step 6: Installing Vim Plugins"

    # Install vim-plug if not present
    VIM_PLUG="$HOME/.vim/autoload/plug.vim"
    if [ ! -f "$VIM_PLUG" ]; then
        print_info "Installing vim-plug..."
        if [ "$DRY_RUN" = false ]; then
            curl -fLo "$VIM_PLUG" --create-dirs \
                https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
            print_success "vim-plug installed"
        else
            print_info "Would install vim-plug"
        fi
    else
        print_success "vim-plug already installed"
    fi

    # Install plugins
    if [ "$DRY_RUN" = false ]; then
        print_info "Installing Vim plugins (this may take a moment)..."
        vim +PlugInstall +qall
        print_success "Vim plugins installed"
    else
        print_info "Would run: vim +PlugInstall +qall"
    fi
}

setup_secrets() {
    print_header "Step 7: Setting Up Secrets"

    if [ ! -f "$HOME/.env.local" ]; then
        print_warning "No ~/.env.local file found"
        print_info "Creating from template: $DOTFILES_DIR/templates/env.local.template"

        if [ "$DRY_RUN" = false ]; then
            cp "$DOTFILES_DIR/templates/env.local.template" "$HOME/.env.local"
            print_success "Created ~/.env.local"
            print_warning "⚠️  IMPORTANT: Edit ~/.env.local and add your API keys!"
        else
            print_info "Would copy template to ~/.env.local"
        fi
    else
        print_success "~/.env.local already exists"
    fi
}

final_steps() {
    print_header "Step 8: Final Setup"

    # Set Zsh as default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_info "Setting Zsh as default shell..."
        if [ "$DRY_RUN" = false ]; then
            chsh -s "$(which zsh)"
            print_success "Default shell changed to Zsh"
        else
            print_info "Would run: chsh -s $(which zsh)"
        fi
    else
        print_success "Zsh is already the default shell"
    fi

    print_info "\nNeovim plugins will be installed automatically on first launch."
    print_info "You can also manually run :Lazy sync in Neovim."
}

print_summary() {
    print_header "Installation Complete!"

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}This was a dry run. No changes were made.${NC}"
        echo -e "${YELLOW}Run without --dry-run to perform the actual installation.${NC}\n"
        return
    fi

    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${GREEN}✓${NC} Backups saved to: $BACKUP_DIR"
    fi

    echo -e "\n${GREEN}✓${NC} All configurations installed successfully!"
    echo -e "\n${YELLOW}⚠️  ACTION REQUIRED:${NC}"
    echo -e "  1. Edit ${BLUE}~/.env.local${NC} and add your API keys"
    echo -e "  2. Restart your terminal or run: ${BLUE}source ~/.zshrc${NC}"
    echo -e "  3. Open Neovim and let plugins install automatically"
    echo -e "\n${BLUE}ℹ${NC}  For more information, see: $DOTFILES_DIR/README.md"
    echo ""
}

################################################################################
# Main Execution
################################################################################

main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                   Dotfiles Bootstrap Script                      ║"
    echo "║                                                                  ║"
    echo "║  This script will set up your Mac with all configurations       ║"
    echo "║  from the dotfiles repository.                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"

    # Verify we're in the right directory
    if [ ! -f "$DOTFILES_DIR/scripts/bootstrap.sh" ]; then
        print_error "Please run this script from $DOTFILES_DIR/scripts/"
        exit 1
    fi

    # Run installation steps
    install_homebrew
    install_brew_packages
    install_python_packages
    install_oh_my_zsh
    setup_symlinks
    install_vim_plugins
    setup_secrets
    final_steps
    print_summary
}

# Run main function
main "$@"
