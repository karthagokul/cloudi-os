#!/bin/bash
set -e

echo '[2.2.5] Installing XFCE and system packages...'

apt-get update

apt-get install -y sudo casper initramfs-tools udev \
network-manager net-tools wireless-tools wpasupplicant \
grub-common grub-pc grub-efi-amd64-signed \
lightdm xfce4 xfce4-goodies curl wget vim nano git xz-utils \
plank gnome-themes-extra gtk2-engines-murrine \
dbus-x11 mesa-utils libgl1-mesa-dri \
mesa-vulkan-drivers xserver-xorg-video-qxl xserver-xorg-input-all \
pulseaudio libpulse0 pavucontrol policykit-1-gnome  xfce4-session

apt-get install -y --no-install-recommends linux-generic linux-headers-generic
echo "lightdm shared/default-x-display-manager select lightdm" | debconf-set-selections
