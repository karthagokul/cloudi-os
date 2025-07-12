#!/bin/bash
set -e
source ./common_config.sh

echo "========== [STEP 2/4] Customize Chroot =========="

# ------------------------------------------------------------------------------
# Function: unmount_stale_mounts
# ------------------------------------------------------------------------------
unmount_stale_mounts() {
  echo "[2.1] Unmounting stale chroot mounts..."
  for m in proc sys dev/pts dev run; do
    sudo umount -lf "$CHROOT_DIR/$m" 2>/dev/null || true
  done
}

# ------------------------------------------------------------------------------
# Function: customize_chroot
# ------------------------------------------------------------------------------
customize_chroot() {
  if [ ! -d "$CHROOT_DIR" ]; then
    echo "[ERROR] Chroot directory not found at $CHROOT_DIR"
    exit 1
  fi

  echo "[2.2] Preparing to configure chrooted base system..."

  echo "[2.2.a] Copying modular chroot scripts..."
  sudo mkdir -p "$CHROOT_DIR/root/chroot_scripts"
  sudo cp -r ./chroot_scripts/* "$CHROOT_DIR/root/chroot_scripts/"
  sudo find "$CHROOT_DIR/root/chroot_scripts/" -type f -name "*.sh" -exec chmod +x {} \;

  echo "[2.2.b] Entering chroot to run modular chroot scripts..."
  sudo chroot "$CHROOT_DIR" env DEBIAN_FRONTEND=noninteractive DISTRIBUTION="$DISTRIBUTION" /bin/bash -c "/root/chroot_scripts/chroot_configure.sh"

  echo "[2.2.c] Cleaning up chroot script directory..."
  sudo rm -rf "$CHROOT_DIR/root/chroot_scripts"
}




# ------------------------------------------------------------------------------
# Function: unmount_bind_mounts
# ------------------------------------------------------------------------------
unmount_bind_mounts() {
  echo "[2.3] Unmounting bind mounts from host..."
  sudo umount "$CHROOT_DIR/dev" || true
  sudo umount "$CHROOT_DIR/run" || true
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
unmount_stale_mounts
customize_chroot
unmount_bind_mounts

echo "[✔] Step 2 complete. You can now run: ./script_3_prepare_image_structure.sh"
