#!/usr/bin/env bash
# ==============================================================================
# Restore User Dotfiles & App Configs
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[*] Creating user configuration directories..."
mkdir -p "$HOME/.config/MangoHud"
mkdir -p "$HOME/.config/goverlay"
mkdir -p "$HOME/.config/dell-g15-rgb"
mkdir -p "$HOME/.config/dell-power"
mkdir -p "$HOME/.config/autostart"
mkdir -p "$HOME/.local/bin"

echo "[*] Copying application configs..."
cp "$SCRIPT_DIR/config/MangoHud/MangoHud.conf" "$HOME/.config/MangoHud/"
cp "$SCRIPT_DIR/config/goverlay/MangoHud.conf" "$HOME/.config/goverlay/"
cp "$SCRIPT_DIR/config/dell-g15-rgb/config.json" "$HOME/.config/dell-g15-rgb/"
cp "$SCRIPT_DIR/config/dell-power/config.json" "$HOME/.config/dell-power/"
cp "$SCRIPT_DIR/config/gamemode.ini" "$HOME/.config/gamemode.ini"
cp "$SCRIPT_DIR/config/autostart/"*.desktop "$HOME/.config/autostart/"

echo "[*] Installing helper scripts to ~/.local/bin..."
install -m 0755 "$SCRIPT_DIR/bin/setup-monitors.sh" "$HOME/.local/bin/setup-monitors.sh"

echo "[*] Restoring shell aliases & gitconfig..."
if [ -f "$SCRIPT_DIR/bash_aliases" ]; then
    cp "$SCRIPT_DIR/bash_aliases" "$HOME/.bash_aliases"
fi

if [ -f "$SCRIPT_DIR/gitconfig" ] && [ ! -f "$HOME/.gitconfig" ]; then
    cp "$SCRIPT_DIR/gitconfig" "$HOME/.gitconfig"
fi

echo "[+] User dotfiles restored successfully!"
