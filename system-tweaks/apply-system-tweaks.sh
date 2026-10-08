#!/usr/bin/env bash
# ==============================================================================
# Apply System Tweaks & Hardware Fixes (Dell G15 5515 / NVIDIA RTX 3060)
# ==============================================================================
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "[-] Please run as root (or via sudo)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="${SUDO_USER:-$USER}"

echo "[*] Step 1: Installing NVIDIA GSP firmware fix (Fixes HDMI & Xid 119 RPC timeouts)..."
if [ -f "$SCRIPT_DIR/nvidia/nvidia-gsp-fix.conf" ]; then
    cp "$SCRIPT_DIR/nvidia/nvidia-gsp-fix.conf" /etc/modprobe.d/nvidia-gsp-fix.conf
fi

echo "[*] Step 2: Updating initramfs to ensure early boot NVIDIA configuration..."
update-initramfs -u -k all

echo "[*] Step 3: Installing gaming kernel sysctl tweaks (vm.max_map_count)..."
if [ -f "$SCRIPT_DIR/sysctl/99-gaming.conf" ]; then
    cp "$SCRIPT_DIR/sysctl/99-gaming.conf" /etc/sysctl.d/99-gaming.conf
    sysctl --system >/dev/null 2>&1 || true
fi

echo "[*] Step 4: Configuring GameMode system daemon..."
if [ -f "$SCRIPT_DIR/gamemode/gamemode.ini" ]; then
    cp "$SCRIPT_DIR/gamemode/gamemode.ini" /etc/gamemode.ini
fi
usermod -aG gamemode "$TARGET_USER" 2>/dev/null || true

echo "[*] Step 5: Installing prime-run launcher wrapper..."
if [ -f "$SCRIPT_DIR/bin/prime-run" ]; then
    install -m 0755 "$SCRIPT_DIR/bin/prime-run" /usr/local/bin/prime-run
fi

echo "[*] Step 6: Installing Dell AWCC & AlienFX USB/HID udev rules..."
if [ -f "$SCRIPT_DIR/udev/70-awcc.rules" ]; then
    cp "$SCRIPT_DIR/udev/70-awcc.rules" /etc/udev/rules.d/70-awcc.rules
fi
if [ -f "$SCRIPT_DIR/udev/99-dell-alienfx-rgb.rules" ]; then
    cp "$SCRIPT_DIR/udev/99-dell-alienfx-rgb.rules" /etc/udev/rules.d/99-dell-alienfx-rgb.rules
fi
udevadm control --reload-rules && udevadm trigger || true

echo "[*] Step 7: Masking conflicting Dell keyboard backlight service..."
systemctl mask systemd-backlight@leds:dell::kbd_backlight.service >/dev/null 2>&1 || true

echo "[+] System tweaks applied successfully!"
