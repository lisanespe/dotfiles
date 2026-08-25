#!/bin/bash

# Dotfiles Setup Script
# This script creates symlinks from the dotfiles repository to their proper locations

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

backup_existing() {
    local target="$1"
    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        log_warning "Backing up existing $target to $BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
    elif [[ -L "$target" ]]; then
        log_info "Removing existing symlink: $target"
        rm "$target"
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    
    if [[ ! -e "$source" ]]; then
        log_error "Source file does not exist: $source"
        return 1
    fi
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # Backup existing file/symlink
    backup_existing "$target"
    
    # Create the symlink
    ln -sf "$source" "$target"
    log_success "Created symlink: $target -> $source"
}

main() {
     log_info "Setting up dotfiles from $DOTFILES_DIR"

    # Shell configuration
    create_symlink "$DOTFILES_DIR/config/shell/.bashrc" "$HOME/.bashrc"

    # Hyprland configuration
    create_symlink "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"

    # Waybar configuration
    create_symlink "$DOTFILES_DIR/config/waybar" "$HOME/.config/waybar"

    # Kitty configuration
    create_symlink "$DOTFILES_DIR/config/misc/kitty" "$HOME/.config/kitty"

    # Neovim configuration
    create_symlink "$DOTFILES_DIR/config/misc/nvim" "$HOME/.config/nvim"

    create_symlink "$DOTFILES_DIR/config/jellyfin/jellyfin.container" \
    "$HOME/.config/containers/systemd/jellyfin.container"

    # Git configuration (if exists)
    if [[ -f "$DOTFILES_DIR/config/git/.gitconfig" ]]; then
        create_symlink "$DOTFILES_DIR/config/git/.gitconfig" "$HOME/.gitconfig"
    fi

       if   command -v systemctl >/dev/null 2>&1; then
            systemctl --user daemon-reload || true
            systemctl --user enable ssh-agent.socket || true
            log_success "ssh-agent.socket enabled"
       fi

    log_success "Dotfiles setup completed!"
    
    if [[ -d "$BACKUP_DIR" ]]; then
        log_info "Original files backed up to: $BACKUP_DIR"
    fi
    
    log_info "You may need to restart your shell or run 'source ~/.bashrc' to apply changes"
    # SSH client config (keys are NOT in this repo)
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    create_symlink "$DOTFILES_DIR/config/ssh/config" "$HOME/.ssh/config"
}

# Check if running from the right directory
if [[ ! -f "$DOTFILES_DIR/scripts/setup.sh" ]]; then
    log_error "Please run this script from the dotfiles repository"
    exit 1
fi

main "$@"
