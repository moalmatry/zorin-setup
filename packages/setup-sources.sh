#!/usr/bin/env bash
# ==============================================================================
# Setup APT Repositories & Architectures
# ==============================================================================
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "[-] Please run as root (or via sudo)"
    exit 1
fi

echo "[*] Adding 32-bit (i386) architecture support..."
dpkg --add-architecture i386

echo "[*] Setting up Brave Browser repository..."
install -d -m 0755 /etc/apt/keyrings
if [ ! -f /usr/share/keyrings/brave-browser-archive-keyring.gpg ]; then
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
fi

cat << 'EOF' > /etc/apt/sources.list.d/brave-browser-release.list
deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main
EOF

echo "[*] Updating APT package cache..."
apt-get update
echo "[+] Package sources configured successfully!"
