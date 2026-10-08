#!/usr/bin/env bash
# ==============================================================================
# Zorin OS 17 (Ubuntu 24.04) Automated Setup & Restoration Script
# Target: Dell G15 5515 (AMD Ryzen 5800H + NVIDIA GeForce RTX 3060 Mobile)
# ==============================================================================
# Usage:
#   ./install.sh         # Runs full installation & setup
#   ./install.sh --help  # Displays available flags & modular options
# ==============================================================================
set -euo pipefail

# ANSI Color codes for clean output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$CURRENT_USER" | cut -d: -f6)

log_info() {
    echo -e "${BLUE}[*]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[-]${NC} $1"
}

log_header() {
    echo -e "\n${CYAN}${BOLD}=== $1 ===${NC}"
}

# Request sudo credentials upfront if needed
require_sudo() {
    if [ "$EUID" -ne 0 ]; then
        log_info "Elevated permissions required. Authenticating with sudo..."
        sudo -v
        # Keep sudo timestamp updated in background
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi
}

run_as_user() {
    if [ "$EUID" -eq 0 ]; then
        sudo -u "$CURRENT_USER" "$@"
    else
        "$@"
    fi
}

run_as_root() {
    if [ "$EUID" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

# ------------------------------------------------------------------------------
# STEP 1: Repository & Package Architecture Setup
# ------------------------------------------------------------------------------
step_repositories() {
    log_header "Step 1: Configuring Package Sources & Architecture"
    require_sudo
    run_as_root "$SCRIPT_DIR/packages/setup-sources.sh"
    log_success "Package sources and 32-bit architecture ready."
}

# ------------------------------------------------------------------------------
# STEP 2: Install APT Packages
# ------------------------------------------------------------------------------
step_apt_packages() {
    log_header "Step 2: Installing APT Packages"
    require_sudo
    local PKG_FILE="$SCRIPT_DIR/packages/apt-packages.txt"
    if [ -f "$PKG_FILE" ]; then
        # Filter comments and empty lines
        local PKG_LIST=()
        while IFS= read -r line || [ -n "$line" ]; do
            line=$(echo "$line" | sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            if [ -n "$line" ]; then
                PKG_LIST+=("$line")
            fi
        done < "$PKG_FILE"

        log_info "Installing ${#PKG_LIST[@]} curated APT packages..."
        run_as_root apt-get install -y "${PKG_LIST[@]}"
        log_success "APT packages installed successfully."
    else
        log_warn "APT package list file not found: $PKG_FILE"
    fi
}

# ------------------------------------------------------------------------------
# STEP 3: Install Flatpak Applications
# ------------------------------------------------------------------------------
step_flatpaks() {
    log_header "Step 3: Setting Up Flatpak & Installing Apps"
    require_sudo
    run_as_root apt-get install -y flatpak

    log_info "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    local FLATPAK_FILE="$SCRIPT_DIR/packages/flatpak-apps.txt"
    if [ -f "$FLATPAK_FILE" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            app_id=$(echo "$line" | sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            if [ -n "$app_id" ]; then
                log_info "Installing Flatpak: $app_id..."
                flatpak install -y --noninteractive flathub "$app_id" || true
            fi
        done < "$FLATPAK_FILE"
        log_success "Flatpak applications installed."
    fi
}

# ------------------------------------------------------------------------------
# STEP 4: System Tweaks & Hardware Optimizations (Dell G15 / RTX 3060)
# ------------------------------------------------------------------------------
step_system_tweaks() {
    log_header "Step 4: Applying Hardware Fixes & Gaming Optimizations"
    require_sudo
    run_as_root "$SCRIPT_DIR/system-tweaks/apply-system-tweaks.sh"
    log_success "Hardware fixes and gaming optimizations applied."
}

# ------------------------------------------------------------------------------
# STEP 5: Desktop Settings & Display Configuration
# ------------------------------------------------------------------------------
step_desktop_settings() {
    log_header "Step 5: Restoring Desktop & Display Settings"
    run_as_user "$SCRIPT_DIR/desktop-settings/apply-desktop-settings.sh"
    log_success "Desktop settings and display configuration restored."
}

# ------------------------------------------------------------------------------
# STEP 6: User Dotfiles & App Configs
# ------------------------------------------------------------------------------
step_dotfiles() {
    log_header "Step 6: Restoring User Dotfiles & Application Configs"
    run_as_user "$SCRIPT_DIR/dotfiles/install-dotfiles.sh"
    log_success "Dotfiles and app configs restored."
}

# ------------------------------------------------------------------------------
# STEP 7: Dell G15 Custom Tools (RGB, G-Mode, Power Manager)
# ------------------------------------------------------------------------------
step_dell_tools() {
    log_header "Step 7: Installing Dell G15 5515 Custom Tools"
    run_as_user "$SCRIPT_DIR/dell-tools/install-dell-tools.sh"
    log_success "Dell G15 custom tools installed and running."
}

# ------------------------------------------------------------------------------
# Usage Information
# ------------------------------------------------------------------------------
show_help() {
    echo "Usage: ./install.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  --all        (Default) Run complete system setup and restoration"
    echo "  --apps       Install only APT and Flatpak applications"
    echo "  --system     Apply only kernel, NVIDIA, and hardware tweaks"
    echo "  --settings   Apply only desktop settings, displays, and dotfiles"
    echo "  --dell       Install only Dell G15 hardware tools (RGB, G-Mode, Power)"
    echo "  --help       Show this help message"
}

# ------------------------------------------------------------------------------
# Main Flow
# ------------------------------------------------------------------------------
main() {
    echo -e "${CYAN}${BOLD}"
    echo "=============================================================================="
    echo "      Zorin OS Automated Setup & System Restoration (Dell G15 5515)           "
    echo "=============================================================================="
    echo -e "${NC}"

    local MODE="${1:---all}"

    case "$MODE" in
        --all)
            step_repositories
            step_apt_packages
            step_flatpaks
            step_system_tweaks
            step_desktop_settings
            step_dotfiles
            step_dell_tools
            ;;
        --apps)
            step_repositories
            step_apt_packages
            step_flatpaks
            ;;
        --system)
            step_system_tweaks
            ;;
        --settings)
            step_desktop_settings
            step_dotfiles
            ;;
        --dell)
            step_dell_tools
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $MODE"
            show_help
            exit 1
            ;;
    esac

    echo -e "\n${GREEN}${BOLD}==============================================================================${NC}"
    echo -e "${GREEN}${BOLD}                   🎉 Setup Completed Successfully!                           ${NC}"
    echo -e "${GREEN}${BOLD}==============================================================================${NC}"
    echo -e "All applications, settings, hardware fixes, and dotfiles have been restored."
    echo -e "${YELLOW}${BOLD}[!] Recommended:${NC} Please reboot your laptop to ensure the new NVIDIA kernel"
    echo -e "    firmware settings and udev rules load cleanly from boot."
}

main "$@"
