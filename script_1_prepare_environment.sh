#!/bin/bash
set -e
source ./common_config.sh
echo "[1/4] Installing dependencies and preparing build dirs..."
sudo apt-get update
sudo apt-get install -y debootstrap squashfs-tools xorriso syslinux-common mtools unzip grub-pc-bin grub-efi-amd64-bin curl wget gnupg apt-transport-https
echo "[1/4] Cleaning previous builds..."
sudo rm -rf "$CHROOT_DIR" "$IMAGE_DIR" "$BUILD_DIR/$ISO_NAME"
mkdir -p "$CHROOT_DIR"
echo "[1/4] Bootstrapping minimal Ubuntu..."
sudo debootstrap --arch="$ARCH" --variant=minbase "$DISTRIBUTION" "$CHROOT_DIR" "$UBUNTU_MIRROR"
echo "[1/4] Mounting /dev and /run..."
sudo mount --bind /dev "$CHROOT_DIR/dev"
sudo mount --bind /run "$CHROOT_DIR/run"
echo "[1/4] Done. Run script_2_customize_chroot.sh next."
