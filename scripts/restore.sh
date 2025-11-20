#!/usr/bin/env bash
################################################################################
# restore.sh - Restore dotfiles from backup
#
# This script helps restore your dotfiles from a backup created during
# bootstrap installation.
#
# Usage:
#   ./scripts/restore.sh              # List available backups
#   ./scripts/restore.sh <backup_dir> # Restore from specific backup
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

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

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

list_backups() {
    print_header "Available Backups"

    local backup_dirs=(~/.dotfiles_backup_*)

    if [[ ${#backup_dirs[@]} -eq 0 ]] || [[ ! -d "${backup_dirs[0]}" ]]; then
        print_info "No backups found"
        echo ""
        echo "Backups are created automatically by bootstrap.sh when files are replaced."
        return 1
    fi

    echo "Found backups:"
    echo ""

    for dir in "${backup_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            local basename=$(basename "$dir")
            local file_count=$(ls -1 "$dir" | wc -l)
            echo "  $basename ($file_count files)"
        fi
    done

    echo ""
    echo "To restore a backup, run:"
    echo "  ./scripts/restore.sh <backup_name>"
}

restore_backup() {
    local backup_dir="$1"

    # If relative path, prepend home directory
    if [[ ! "$backup_dir" =~ ^/ ]]; then
        backup_dir="$HOME/$backup_dir"
    fi

    if [[ ! -d "$backup_dir" ]]; then
        print_error "Backup directory not found: $backup_dir"
        return 1
    fi

    print_header "Restoring from backup: $(basename "$backup_dir")"

    print_info "Files in backup:"
    ls -1 "$backup_dir" | sed 's/^/  /'
    echo ""

    read -p "Restore these files? This will overwrite current files. (y/N) " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        return 0
    fi

    # Restore each file
    for file in "$backup_dir"/*; do
        local basename=$(basename "$file")
        local target="$HOME/.$basename"

        if [[ -e "$target" ]] || [[ -L "$target" ]]; then
            rm -f "$target"
        fi

        cp -P "$file" "$target"
        print_success "Restored: .$basename"
    done

    print_success "Restore complete!"
    echo ""
    print_info "You may need to restart your shell: source ~/.zshrc"
}

main() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                  Dotfiles Restore Utility                     ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"

    if [[ $# -eq 0 ]]; then
        list_backups
    else
        restore_backup "$1"
    fi
}

main "$@"
