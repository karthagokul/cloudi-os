#!/bin/bash
set -e
source ./common_config.sh

echo "========== [STEP 3/4] Prepare Image Structure =========="

# ------------------------------------------------------------------------------
# Function: create_image_directories
# ------------------------------------------------------------------------------
create_image_directories() {
  echo "[3.1] Creating necessary image directories..."
  mkdir -p "$IMAGE_DIR/casper" "$IMAGE_DIR/isolinux" "$IMAGE_DIR/install"
}

# ------------------------------------------------------------------------------
# Function: get_kernel_version
# ------------------------------------------------------------------------------
get_kernel_version() {
  echo "[3.2] Detecting kernel version..."
  KERNEL_VERSION=$(ls "$CHROOT_DIR/boot" | grep vmlinuz- | sed 's/vmlinuz-//')
  echo "Using kernel: $KERNEL_VERSION"
}

# ------------------------------------------------------------------------------
# Function: copy_kernel_files
# ------------------------------------------------------------------------------
copy_kernel_files() {
  echo "[3.3] Copying kernel and initrd to image directory..."
  sudo cp -vf "$CHROOT_DIR/boot/vmlinuz-$KERNEL_VERSION" "$IMAGE_DIR/casper/vmlinuz"
  sudo cp -vf "$CHROOT_DIR/boot/initrd.img-$KERNEL_VERSION" "$IMAGE_DIR/casper/initrd"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
create_image_directories
get_kernel_version
copy_kernel_files

echo "[✔] Step 3 complete. You can now run: ./script_4_generate_iso.sh"
