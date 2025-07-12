#!/bin/bash
set -e
source ./common_config.sh

echo "========== [STEP 4/4] Generate ISO =========="

# ------------------------------------------------------------------------------
# Function: create_squashfs
# ------------------------------------------------------------------------------
create_squashfs() {
  echo "[1/5] Creating SquashFS from chroot..."
  sudo mksquashfs "$CHROOT_DIR" "$IMAGE_DIR/casper/filesystem.squashfs" -noappend -wildcards -comp xz
  printf $(sudo du -sx --block-size=1 "$CHROOT_DIR" | cut -f1) | sudo tee "$IMAGE_DIR/casper/filesystem.size"
}

# ------------------------------------------------------------------------------
# Function: prepare_isolinux_bios_boot
# ------------------------------------------------------------------------------
prepare_isolinux_bios_boot() {
  echo "[2/5] Preparing ISOLINUX BIOS boot files..."
  mkdir -p "$IMAGE_DIR/isolinux"

  cp /usr/lib/ISOLINUX/isolinux.bin "$IMAGE_DIR/isolinux/"
  cp /usr/lib/syslinux/modules/bios/ldlinux.c32 "$IMAGE_DIR/isolinux/"
  cp /usr/lib/syslinux/modules/bios/libcom32.c32 "$IMAGE_DIR/isolinux/"
  cp /usr/lib/syslinux/modules/bios/vesamenu.c32 "$IMAGE_DIR/isolinux/"
  cp /usr/lib/syslinux/modules/bios/libutil.c32 "$IMAGE_DIR/isolinux/"

  touch "$IMAGE_DIR/isolinux/boot.cat"

  if [ "$SHOW_CONSOLE_LOGS" = true ]; then
    KERNEL_PARAMS="initrd=/casper/initrd boot=casper console=ttyS0,115200n8"
  else
    KERNEL_PARAMS="initrd=/casper/initrd boot=casper quiet splash"
  fi

  cat <<EOF | sudo tee "$IMAGE_DIR/isolinux/isolinux.cfg"
UI vesamenu.c32
DEFAULT live
PROMPT 0
TIMEOUT 50

MENU TITLE Cloudify OS Boot Menu

LABEL live
    MENU LABEL Try Cloudify OS
    KERNEL /casper/vmlinuz
    APPEND $KERNEL_PARAMS
EOF
}

# ------------------------------------------------------------------------------
# Function: create_efi_boot_image
# ------------------------------------------------------------------------------
create_efi_boot_image() {
  echo "[3/5] Creating EFI boot image..."
  mkdir -p "$IMAGE_DIR/EFI/BOOT"

  grub-mkstandalone \
    --format=x86_64-efi \
    --output="$IMAGE_DIR/bootx64.efi" \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$IMAGE_DIR/isolinux/isolinux.cfg"

  dd if=/dev/zero of="$IMAGE_DIR/efiboot.img" bs=1M count=20
  mkfs.vfat "$IMAGE_DIR/efiboot.img"
  mmd -i "$IMAGE_DIR/efiboot.img" ::/EFI
  mmd -i "$IMAGE_DIR/efiboot.img" ::/EFI/BOOT
  mcopy -vi "$IMAGE_DIR/efiboot.img" "$IMAGE_DIR/bootx64.efi" ::/EFI/BOOT/
}

# ------------------------------------------------------------------------------
# Function: generate_final_iso
# ------------------------------------------------------------------------------
generate_final_iso() {
  echo "[4/5] Generating final ISO (Hybrid EFI + BIOS)..."
  cd "$IMAGE_DIR"

  sudo xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "Cloudify_OS" \
    -output "../$ISO_NAME" \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -c isolinux/boot.cat \
    -b isolinux/isolinux.bin \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
    -eltorito-alt-boot \
    -e efiboot.img \
        -no-emul-boot \
    -isohybrid-gpt-basdat \
    .
}

# ------------------------------------------------------------------------------
# Function: show_success_message
# ------------------------------------------------------------------------------
show_success_message() {
  echo ""
  echo "✅ ISO created successfully at: $BUILD_DIR/$ISO_NAME"
  echo "✅ Test using:"
  echo "qemu-system-x86_64 -m 2048 -serial mon:stdio -cdrom $BUILD_DIR/$ISO_NAME"
  echo ""
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
create_squashfs
prepare_isolinux_bios_boot
create_efi_boot_image
generate_final_iso
show_success_message
