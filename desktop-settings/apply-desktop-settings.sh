#!/usr/bin/env bash
# ==============================================================================
# Apply Desktop Settings, Themes & Display Configuration
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[*] Enabling Mutter fractional scaling features on X11..."
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'x11-randr-fractional-scaling']"

echo "[*] Loading GNOME & Zorin dconf desktop configurations..."
if [ -f "$SCRIPT_DIR/dconf-settings.ini" ]; then
    dconf load / < "$SCRIPT_DIR/dconf-settings.ini"
    echo "[+] dconf settings applied!"
fi

echo "[*] Restoring display configuration (125% scale & underscan fix)..."
mkdir -p "$HOME/.config"
if [ -f "$SCRIPT_DIR/monitors.xml" ]; then
    cp "$SCRIPT_DIR/monitors.xml" "$HOME/.config/monitors.xml"
    echo "[+] monitors.xml restored to ~/.config/monitors.xml"
fi

echo "[*] Verifying core interface settings..."
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
gsettings set org.gnome.shell.extensions.zorin-taskbar panel-size 48 2>/dev/null || true
gsettings set org.gnome.shell.extensions.zorin-menu layout 'ALL' 2>/dev/null || true

echo "[+] Desktop settings restoration completed!"
