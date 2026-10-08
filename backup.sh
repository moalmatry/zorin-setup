#!/usr/bin/env bash
# ==============================================================================
# Zorin OS Setup - System Backup & Export Utility
# ==============================================================================
# Run this script anytime to capture your current settings, app list,
# and configurations into this repository before pushing to GitHub.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=============================================================================="
echo "          Backing up Zorin OS Settings, Packages & Configurations            "
echo "=============================================================================="

# 1. Desktop & dconf Settings
echo "[*] Exporting GNOME & Zorin dconf settings..."
dconf dump / > "$SCRIPT_DIR/desktop-settings/dconf-settings.ini"

if [ -f "$HOME/.config/monitors.xml" ]; then
    echo "[*] Exporting display configuration..."
    cp "$HOME/.config/monitors.xml" "$SCRIPT_DIR/desktop-settings/monitors.xml"
fi

# 2. Installed Flatpak Applications
if command -v flatpak &>/dev/null; then
    echo "[*] Exporting Flatpak applications list..."
    echo "# Flatpak Applications List" > "$SCRIPT_DIR/packages/flatpak-apps.txt"
    flatpak list --app --columns=application | grep -v '^$' >> "$SCRIPT_DIR/packages/flatpak-apps.txt" || true
fi

# 3. User Application Dotfiles
echo "[*] Exporting user configuration files..."
[ -f "$HOME/.config/MangoHud/MangoHud.conf" ] && cp "$HOME/.config/MangoHud/MangoHud.conf" "$SCRIPT_DIR/dotfiles/config/MangoHud/"
[ -f "$HOME/.config/goverlay/MangoHud.conf" ] && cp "$HOME/.config/goverlay/MangoHud.conf" "$SCRIPT_DIR/dotfiles/config/goverlay/"
[ -f "$HOME/.config/dell-g15-rgb/config.json" ] && cp "$HOME/.config/dell-g15-rgb/config.json" "$SCRIPT_DIR/dotfiles/config/dell-g15-rgb/"
[ -f "$HOME/.config/dell-power/config.json" ] && cp "$HOME/.config/dell-power/config.json" "$SCRIPT_DIR/dotfiles/config/dell-power/"
[ -f "$HOME/.config/gamemode.ini" ] && cp "$HOME/.config/gamemode.ini" "$SCRIPT_DIR/dotfiles/config/"
[ -d "$HOME/.config/autostart" ] && cp "$HOME/.config/autostart/"*.desktop "$SCRIPT_DIR/dotfiles/config/autostart/" 2>/dev/null || true
[ -f "$HOME/.local/bin/setup-monitors.sh" ] && cp "$HOME/.local/bin/setup-monitors.sh" "$SCRIPT_DIR/dotfiles/bin/"
[ -f "$HOME/.bash_aliases" ] && cp "$HOME/.bash_aliases" "$SCRIPT_DIR/dotfiles/bash_aliases"
[ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$SCRIPT_DIR/dotfiles/gitconfig"

# 4. System Tweaks & Hardware Rules
echo "[*] Exporting system tweaks..."
[ -f "/etc/modprobe.d/nvidia-gsp-fix.conf" ] && cp "/etc/modprobe.d/nvidia-gsp-fix.conf" "$SCRIPT_DIR/system-tweaks/nvidia/"
[ -f "/etc/sysctl.d/99-gaming.conf" ] && cp "/etc/sysctl.d/99-gaming.conf" "$SCRIPT_DIR/system-tweaks/sysctl/"
[ -f "/etc/gamemode.ini" ] && cp "/etc/gamemode.ini" "$SCRIPT_DIR/system-tweaks/gamemode/"
[ -f "/etc/udev/rules.d/70-awcc.rules" ] && cp "/etc/udev/rules.d/70-awcc.rules" "$SCRIPT_DIR/system-tweaks/udev/"
[ -f "/etc/udev/rules.d/99-dell-alienfx-rgb.rules" ] && cp "/etc/udev/rules.d/99-dell-alienfx-rgb.rules" "$SCRIPT_DIR/system-tweaks/udev/"
[ -f "/usr/local/bin/prime-run" ] && cp "/usr/local/bin/prime-run" "$SCRIPT_DIR/system-tweaks/bin/"

echo "=============================================================================="
echo "[+] Backup complete! Changes captured in repository."
echo "=============================================================================="
git -C "$SCRIPT_DIR" status --short
