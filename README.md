# 🏠 My Dotfiles

Personal configuration files for my Arch Linux + Hyprland setup.

## 📁 Structure

```
dotfiles/
├── config/
│   ├── hypr/           # Hyprland window manager config
│   ├── waybar/         # Status bar configuration  
│   ├── shell/          # Shell configuration (bashrc)
│   ├── git/            # Git configuration
│   └── misc/           # Other configs (kitty, nvim, etc.)
├── scripts/
│   └── setup.sh        # Installation script
└── docs/               # Documentation
```

## 🚀 Quick Setup

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. **Run the setup script:**
   ```bash
   ./scripts/setup.sh
   ```

3. **Restart your shell or source bashrc:**
   ```bash
   source ~/.bashrc
   ```

## 📋 What's Included

- **Hyprland**: Wayland compositor configuration with custom keybindings
- **Waybar**: Status bar with system information
- **Kitty**: Terminal emulator configuration
- **Bash**: Shell configuration with custom prompt and history settings
- **Neovim**: Text editor configuration

## 🛠️ Manual Installation

If you prefer to set up symlinks manually:

```bash
# Shell configuration
ln -sf ~/dotfiles/config/shell/bashrc ~/.bashrc

# Hyprland
ln -sf ~/dotfiles/config/hypr/hypr ~/.config/hypr

# Waybar  
ln -sf ~/dotfiles/config/waybar/waybar ~/.config/waybar

# Other configs
ln -sf ~/dotfiles/config/misc/kitty ~/.config/kitty
ln -sf ~/dotfiles/config/misc/nvim ~/.config/nvim
```

## 🔄 Updating Configs

To update your dotfiles repository with new changes:

1. **Make changes to files in the dotfiles directory**
2. **Commit and push:**
   ```bash
   git add .
   git commit -m "Update configurations"
   git push
   ```

## 📝 Notes

- The setup script automatically backs up existing configurations
- Symlinks allow live editing - changes in dotfiles directory immediately apply
- History is limited to 1000 commands in memory, 2000 in file
- Fastfetch runs once per terminal session

## 🖥️ System Info

- **OS**: Arch Linux
- **WM**: Hyprland
- **Terminal**: Kitty  
- **Shell**: Bash
- **Editor**: Neovim
- **Bar**: Waybar