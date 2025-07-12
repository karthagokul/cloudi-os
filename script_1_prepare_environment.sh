#!/bin/bash
set -e

source ./common_config.sh

echo "========== [STEP 1/4] Prepare Chroot Environment =========="

# ------------------------------------------------------------------------------
# Function: install_dependencies
# ------------------------------------------------------------------------------
install_dependencies() {
  echo "[1.1] Installing build dependencies..."
  sudo apt-get update
  sudo apt-get install -y \
    debootstrap squashfs-tools xorriso syslinux-common mtools \
    unzip grub-pc-bin grub-efi-amd64-bin \
    curl wget gnupg apt-transport-https
}

# ------------------------------------------------------------------------------
# Function: unmount_chroot_mounts
# ------------------------------------------------------------------------------
unmount_chroot_mounts() {
  echo "[1.2] Checking for active chroot mounts to unmount..."
  local mounts=(proc sys dev/pts dev run)
  for m in "${mounts[@]}"; do
    if mountpoint -q "$CHROOT_DIR/$m"; then
      echo "Unmounting: $CHROOT_DIR/$m"
      sudo umount -lf "$CHROOT_DIR/$m"
    fi
  done
}

# ------------------------------------------------------------------------------
# Function: clean_previous_build
# ------------------------------------------------------------------------------
clean_previous_build() {
  echo "[1.3] Cleaning previous build directories..."
  unmount_chroot_mounts
  sudo rm -rf "$CHROOT_DIR" "$IMAGE_DIR" "$BUILD_DIR/$ISO_NAME"
  mkdir -p "$CHROOT_DIR"
}

# ------------------------------------------------------------------------------
# Function: bootstrap_ubuntu
# ------------------------------------------------------------------------------
bootstrap_ubuntu() {
  echo "[1.4] Bootstrapping minimal Ubuntu base ($DISTRIBUTION)..."
  sudo debootstrap --arch="$ARCH" --variant=minbase "$DISTRIBUTION" "$CHROOT_DIR" "$UBUNTU_MIRROR"
}

# ------------------------------------------------------------------------------
# Function: mount_virtual_filesystems
# ------------------------------------------------------------------------------
mount_virtual_filesystems() {
  echo "[1.5] Mounting virtual filesystems..."
  sudo mount --bind /dev "$CHROOT_DIR/dev"
  sudo mount --bind /run "$CHROOT_DIR/run"
}

# ------------------------------------------------------------------------------
# Main Execution
# ------------------------------------------------------------------------------
install_dependencies
clean_previous_build
bootstrap_ubuntu
mount_virtual_filesystems

echo "Step 1 complete. You can now run: ./script_2_customize_chroot.sh"
