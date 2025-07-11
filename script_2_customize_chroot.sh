#!/bin/bash
set -e
source ./common_config.sh

echo "[2/4] Cleaning stale mounts before customizing chroot..."
for m in proc sys dev/pts dev run; do
    sudo umount -lf "$CHROOT_DIR/$m" 2>/dev/null || true
done

echo "[2/4] Customizing chroot..."

sudo chroot "$CHROOT_DIR" env DEBIAN_FRONTEND=noninteractive /bin/bash <<'EOT'
set -e

# Mount required filesystems
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts

export HOME=/root
export LC_ALL=C

# Set hostname
echo 'cloudify-os-live' > /etc/hostname

# Setup sources
echo 'deb http://us.archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse' > /etc/apt/sources.list

# Update and install essentials
apt-get update
apt-get install -y systemd-sysv

# Setup machine-id and initctl diversion
dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

# Upgrade existing packages
apt-get -y upgrade

# Preseed keyboard to suppress prompts
echo 'keyboard-configuration  keyboard-configuration/layoutcode select us' | debconf-set-selections
echo 'keyboard-configuration  keyboard-configuration/modelcode select pc105' | debconf-set-selections
echo 'keyboard-configuration  keyboard-configuration/xkb-keymap select us' | debconf-set-selections
echo 'keyboard-configuration  keyboard-configuration/layout select USA' | debconf-set-selections
echo 'keyboard-configuration  keyboard-configuration/variant select ' | debconf-set-selections

# Preseed locale
echo "locales locales/default_environment_locale select en_US.UTF-8" | debconf-set-selections
echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections

# Install packages for live system and XFCE
apt-get install -y sudo ubuntu-standard casper discover laptop-detect os-prober \
    network-manager net-tools wireless-tools wpagui locales grub-common grub-pc \
    grub-efi-amd64-signed ubiquity ubiquity-frontend-gtk xubuntu-desktop \
    plymouth-themes curl wget vim nano git
apt-get install -y --no-install-recommends linux-generic linux-headers-generic

# Cleanup unused
apt-get autoremove -y

# Generate locales without prompts
locale-gen
update-locale LANG=en_US.UTF-8

# Final cleanup
rm -f /etc/machine-id /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl
apt-get clean
rm -rf /tmp/*

# Unmount filesystems cleanly inside chroot
umount /proc || true
umount /sys || true
umount /dev/pts || true

EOT

# Unmount bind mounts from host
sudo umount "$CHROOT_DIR/dev" || true
sudo umount "$CHROOT_DIR/run" || true

echo "[2/4] Done. Run script_3_prepare_image_structure.sh next."
