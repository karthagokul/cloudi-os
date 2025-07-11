#!/bin/bash
set -e
source ./common_config.sh
echo "[3/4] Preparing image structure..."
mkdir -p "$IMAGE_DIR/casper" "$IMAGE_DIR/isolinux" "$IMAGE_DIR/install"
KERNEL_VERSION=$(ls "$CHROOT_DIR/boot" | grep vmlinuz- | sed 's/vmlinuz-//')
echo "Using kernel: $KERNEL_VERSION"
sudo cp "$CHROOT_DIR/boot/vmlinuz-$KERNEL_VERSION" "$IMAGE_DIR/casper/vmlinuz"
sudo cp "$CHROOT_DIR/boot/initrd.img-$KERNEL_VERSION" "$IMAGE_DIR/casper/initrd"
echo "[3/4] Done. Run script_4_generate_iso.sh next."
