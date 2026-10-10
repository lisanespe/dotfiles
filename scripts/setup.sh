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

# Install pacman packages from packages.txt.
# --needed skips what is already installed, so re-running is cheap.
install_packages() {
    local list
    list=$(grep -vE '^\s*(#|$)' "$DOTFILES_DIR/packages.txt" | sed 's/\s*#.*//')
    log_info "Installing pacman packages"
    # shellcheck disable=SC2086  # word splitting is intended: one arg per package
    sudo pacman -S --needed --noconfirm $list
    log_success "Packages installed"
}

# Install the side-keyboard keyd config into /etc/keyd (root-owned, needs sudo).
# keyd runs as a root system service and starts at boot, before login.
install_keyd_config() {
    local source="$DOTFILES_DIR/config/keyd/default.conf"
    local target="/etc/keyd/default.conf"

    if ! command -v keyd >/dev/null 2>&1; then
        log_warning "keyd not installed, skipping keyd config"
        return 0
    fi

    # Copied, not symlinked: keyd starts at boot and must not depend on $HOME.
    if [[ -f "$target" ]] && ! cmp -s "$source" "$target"; then
        mkdir -p "$BACKUP_DIR"
        log_warning "Backing up existing $target to $BACKUP_DIR"
        sudo cp "$target" "$BACKUP_DIR/keyd-default.conf"
    fi
    sudo install -Dm644 "$source" "$target"

    # Restart keyd automatically if it crashes (stock unit has Restart=no)
    sudo install -Dm644 "$DOTFILES_DIR/config/keyd/keyd.service.d/restart.conf" \
        /etc/systemd/system/keyd.service.d/restart.conf
    sudo systemctl daemon-reload

    # Restart, not `keyd reload`: keyd 2.6.0 segfaults on live reload.
    sudo systemctl restart keyd
    log_success "keyd config installed: $target"
}

main() {
     log_info "Setting up dotfiles from $DOTFILES_DIR"

    # Packages first: later steps need keyd, podman, etc.
    install_packages

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

    # Side keyboard remap (system-wide, needs sudo)
    install_keyd_config

    create_symlink "$DOTFILES_DIR/config/jellyfin/jellyfin.container" \
    "$HOME/.config/containers/systemd/jellyfin.container"

    # Media stack Podman Quadlets (*.container, media.network)
    for unit in "$DOTFILES_DIR"/config/media-stack/*; do
        create_symlink "$unit" "$HOME/.config/containers/systemd/$(basename "$unit")"
    done

    # User services
    create_symlink "$DOTFILES_DIR/config/systemd/user/qbittorrent-nox.service" \
    "$HOME/.config/systemd/user/qbittorrent-nox.service"

    # Session environment (SSH agent socket for systemd user services)
    create_symlink "$DOTFILES_DIR/config/environment.d/ssh-agent.conf" \
    "$HOME/.config/environment.d/10-ssh-agent.conf"

    # Git configuration (if exists)
    if [[ -f "$DOTFILES_DIR/config/git/.gitconfig" ]]; then
        create_symlink "$DOTFILES_DIR/config/git/.gitconfig" "$HOME/.gitconfig"
    fi

       if   command -v systemctl >/dev/null 2>&1; then
            systemctl --user daemon-reload || true
            systemctl --user enable ssh-agent.socket || true
            log_success "ssh-agent.socket enabled"
            systemctl --user enable qbittorrent-nox.service || true
            log_success "qbittorrent-nox.service enabled"
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
