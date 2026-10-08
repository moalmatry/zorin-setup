# 🚀 Zorin OS 17 Automated Setup & Restoration

Complete post-install automation, configuration backup, and hardware fix suite for **Zorin OS 17 (Ubuntu 24.04 LTS)**, tailored for the **Dell G15 5515** (AMD Ryzen 7 5800H + NVIDIA GeForce RTX 3060 Mobile).

Whenever you reinstall Zorin OS or want to sync a fresh machine, running one command restores all your applications, desktop layout, custom hardware tools, and system optimizations in minutes.

---

## ⚡ Quick Start (Fresh Zorin Install)

After a fresh installation of Zorin OS, open a terminal and run:

```bash
# 1. Install Git and clone this repository
sudo apt update && sudo apt install -y git
git clone https://github.com/moalmatry/zorin-setup.git ~/Programming/zorin-setup

# 2. Enter directory and run the automated setup
cd ~/Programming/zorin-setup
./install.sh
```

Once completed, reboot your system to activate all kernel modules, display configs, and udev rules.

---

## 📦 What Gets Installed & Restored

### 1. Applications & Packages
* **Browsers:** Brave Browser (official repository) & Zen Browser (Flatpak).
* **Gaming & Performance:** Steam, Heroic Games Launcher, GameMode, MangoHud, GOverlay, Wine, Winetricks, Vulkan tools, 32-bit graphics drivers (`i386`).
* **Communication & Dev:** Vesktop (Discord), GitHub CLI (`gh`), Git, Curl, Vim, Htop, P7zip.

### 2. Dell G15 5515 Hardware Tools
Automatically clones and installs custom tools from GitHub:
* [dell-g15-rgb](https://github.com/moalmatry/dell-g15-rgb): Alienware 4-zone RGB keyboard lighting control + GUI + login state restoration.
* [dell-gmode](https://github.com/moalmatry/dell-gmode): Alienware Game Shift (G-Key / F9) high-performance fan toggle service.
* [dell-power-manager](https://github.com/moalmatry/dell-power-manager): Custom battery charge limit (e.g. 50–55% for battery longevity) and thermal mode selector with systemd service.

### 3. Hardware Fixes & Kernel Optimizations
* **NVIDIA GSP Firmware Fix:** Disables buggy GSP firmware via `/etc/modprobe.d/nvidia-gsp-fix.conf` to prevent HDMI dropouts and Xid 119 RPC timeouts on RTX 3060 mobile.
* **Dual-Monitor HDMI Support:** Configures reverse PRIME display provider sink hooks and auto-runs `setup-monitors.sh` at login.
* **Display Underscan Fix:** Ensures native edge-to-edge panel output without black borders.
* **Kernel Sysctl Tweaks:** Sets `vm.max_map_count = 2147483642` and `fs.file-max = 2097152` for demanding games (Star Citizen, CS2, Hogwarts Legacy).
* **GameMode Policy:** High-priority CPU governor, screensaver inhibitor, and GPU PowerMizer level.
* **Udev Rules:** Grants non-root access to AlienFX USB/HID devices and masks conflicting systemd backlight services.

### 4. Desktop Settings & Personal Dotfiles
* **Scaling:** 125% Fractional Scaling at native 120Hz refresh rate (saved via Mutter DisplayConfig).
* **Zorin Theme:** Auto theme switching (Light daytime / Dark nighttime).
* **Taskbar & Start Menu:** Proportional 48px panel height with factory Zorin Menu layout.
* **MangoHud:** Custom 3-column gaming overlay layout and keybindings (`Shift_R + F12`).
* **Shell Aliases:** Preconfigured shortcuts (`prime`, `gmode`, `rgb`, `power`, `update`, `clean`).

---

## 🛠️ Modular Installation Options

If you only want to run specific parts of the setup, you can pass flags to `./install.sh`:

```bash
# Full installation (default)
./install.sh

# Install only APT packages and Flatpaks
./install.sh --apps

# Apply only NVIDIA, gaming, and kernel tweaks
./install.sh --system

# Restore only desktop dconf settings and dotfiles
./install.sh --settings

# Install only Dell G15 custom hardware tools
./install.sh --dell

# View help
./install.sh --help
```

---

## 🔄 Updating Your Backup

Whenever you install new software, change desktop preferences, or adjust power settings on your active system, you can refresh this repository with one command:

```bash
cd ~/Programming/zorin-setup
./backup.sh
```

This will automatically export your latest `dconf` settings, monitors config, package lists, and dotfiles into the repo. Then simply push to GitHub:

```bash
git add .
git commit -m "Update system configs and packages"
git push origin main
```

---

## 📁 Repository Structure

```text
zorin-setup/
├── install.sh                  # Master 1-click automated setup script
├── backup.sh                   # System state export & sync utility
├── README.md                   # Documentation & setup guide
├── packages/
│   ├── apt-packages.txt        # Curated APT packages list
│   ├── flatpak-apps.txt        # Flatpak application IDs
│   └── setup-sources.sh        # Adds Brave repo and i386 architecture
├── desktop-settings/
│   ├── dconf-settings.ini      # Full GNOME & Zorin dconf settings dump
│   ├── monitors.xml            # Display geometry (125% scale, 120Hz, underscan off)
│   └── apply-desktop-settings.sh
├── system-tweaks/
│   ├── nvidia/                 # NVIDIA GSP firmware fix (HDMI stability)
│   ├── sysctl/                 # Gaming memory map tweaks
│   ├── gamemode/               # /etc/gamemode.ini configuration
│   ├── udev/                   # Dell AlienFX / AWCC device rules
│   ├── bin/                    # prime-run NVIDIA launcher script
│   └── apply-system-tweaks.sh
├── dotfiles/
│   ├── config/                 # MangoHud, GOverlay, Autostart, Dell configs
│   ├── bin/                    # setup-monitors.sh
│   ├── bash_aliases            # Convenient terminal aliases
│   ├── gitconfig               # Git user config
│   └── install-dotfiles.sh
└── dell-tools/
    └── install-dell-tools.sh   # Clones and installs dell-g15-rgb, dell-gmode, dell-power
```

---

## 👤 Author
**Mohamed Almatry**  
GitHub: [@moalmatry](https://github.com/moalmatry)
