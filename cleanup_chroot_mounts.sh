#!/bin/bash
set -e

CHROOT_DIR="$PWD/build/chroot"

echo "Unmounting chroot mounts..."

for m in proc sys dev/pts dev run; do
    if mountpoint -q "$CHROOT_DIR/$m"; then
        sudo umount -lf "$CHROOT_DIR/$m"
        echo "Unmounted $CHROOT_DIR/$m"
    fi
done

echo "Cleanup complete. You can now safely remove $CHROOT_DIR"

