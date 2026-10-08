#!/usr/bin/env bash
# ==============================================================================
# Setup & Install Dell G15 5515 Custom Hardware Tools
# ==============================================================================
set -euo pipefail

TARGET_DIR="$HOME/Documents/Programming"
mkdir -p "$TARGET_DIR"

echo "[*] Step 1: Ensuring Poetry / Python build tools are installed..."
if ! command -v poetry &>/dev/null; then
    echo "[*] Installing Poetry via official installer..."
    curl -sSL https://install.python-poetry.org | python3 - || true
    export PATH="$HOME/.local/bin:$PATH"
fi

REPOS=(
    "dell-g15-rgb:https://github.com/moalmatry/dell-g15-rgb.git"
    "dell-gmode:https://github.com/moalmatry/dell-gmode.git"
    "dell-power-manager:https://github.com/moalmatry/dell-power-manager.git"
)

echo "[*] Step 2: Cloning and installing Dell G15 tools..."
for entry in "${REPOS[@]}"; do
    NAME="${entry%%:*}"
    URL="${entry#*:}"
    REPO_PATH="$TARGET_DIR/$NAME"

    echo "------------------------------------------------------------------------------"
    echo "Processing $NAME..."
    echo "------------------------------------------------------------------------------"

    if [ ! -d "$REPO_PATH/.git" ]; then
        echo "[*] Cloning $NAME from $URL..."
        git clone "$URL" "$REPO_PATH"
    else
        echo "[*] Repository $NAME already exists. Pulling latest changes..."
        git -C "$REPO_PATH" pull || true
    fi

    if [ -f "$REPO_PATH/install.sh" ]; then
        echo "[*] Running install.sh for $NAME..."
        (
            cd "$REPO_PATH"
            # install.sh uses sudo inside when needed
            ./install.sh
        )
        echo "[+] $NAME installed successfully!"
    else
        echo "[!] No install.sh found in $REPO_PATH"
    fi
done

echo "[+] All Dell G15 custom tools have been installed!"
