#!/bin/bash
set -e
source ./common_config.sh
echo "[4/4] Generating ISO..."
sudo mksquashfs "$CHROOT_DIR" "$IMAGE_DIR/casper/filesystem.squashfs" -noappend -wildcards -comp xz
printf $(sudo du -sx --block-size=1 "$CHROOT_DIR" | cut -f1) | sudo tee "$IMAGE_DIR/casper/filesystem.size"
cd "$IMAGE_DIR"
sudo xorriso -as mkisofs -iso-level 3 -J -joliet-long -r -V "Cloudify OS" -o "../$ISO_NAME" .
echo "[4/4] ISO created at: $BUILD_DIR/$ISO_NAME"
