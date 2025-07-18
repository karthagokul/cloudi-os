- name: Run chroot script {{ item }}
  command: chroot {{ CHROOT_DIR }} /bin/bash /tmp/chroot_scripts/{{ item }}
  with_items:
    - A_base.sh
    - B_machine_id.sh
    - C_locale_keyboard.sh
    - D_packages.sh
    - E_user.sh
    - F_lightdm_network.sh
    - G_initramfs.sh
    - H_services.sh
    - I_theme.sh
    - J_autostart.sh
    - K_xsession.sh
    - L_cleanup.sh
  become: true
# --- Core Desktop & Essentials ---
xubuntu-desktop           # The full XFCE desktop environment
plymouth-themes           # For boot splash
sudo                      # Essential for user management
ubuntu-standard           # Standard Ubuntu base utilities
locales                   # For language support
network-manager           # Network management
net-tools                 # ifconfig, netstat etc.
wireless-tools            # For managing wireless connections
wpagui                    # GUI for WPA supplicant
git                       # Version control
curl                      # Data transfer utility
wget                      # Non-interactive network downloader
vim                       # Powerful text editor
nano                      # Simple text editor
less                      # File pager
build-essential           # For compiling software
cmake                     # Build system generator
unzip                     # For extracting zip files
gnupg                     # For managing GPG keys (for external repos)
apt-transport-https       # For HTTPS APT repositories

# --- Productivity & Office ---
nextcloud-desktop         # Nextcloud desktop client
thunderbird               # Email client with calendar
libreoffice               # Full office suite (Writer, Calc, Impress)
ganttproject              # Gantt chart editor
zim                       # Desktop wiki notebook

# --- Utilities & Enhancements ---
plank                     # macOS-like dock
ulauncher                 # Spotlight-like launcher
conky-all                 # Highly customizable system monitor
copyq                     # Advanced clipboard manager
clamav-daemon             # Antivirus daemon (for security-conscious PMs)
terminator                # Advanced terminal emulator (or xfce4-terminal)
remind                    # CLI reminder tool

# --- For Optional Installations (if you add external repos via hooks) ---
# code                      # Visual Studio Code (requires Microsoft repo)
# google-chrome-stable      # Google Chrome (requires Google repo)
# openjdk-8-jdk             # Java 8 Development Kit
# openjdk-8-jre             # Java 8 Runtime Environment

# --- For Docker & Containerization ---
docker.io                 # Docker Engine
docker-compose            # Docker Compose (often installed as a plugin now)

# --- Python Development (for scripting/tools) ---
python3-pip               # Python package installer
python3-venv              # For creating Python virtual environments

# --- For GPU monitoring (if applicable for your build host) ---
# nvtop                     # NVIDIA GPU monitoring
# radeontop                 # AMD GPU monitoring