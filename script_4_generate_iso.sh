#!/bin/bash
set -e
source ./common_config.sh

echo "[1/5] Generating ISO..."

# Create SquashFS
echo "[2/5] Creating filesystem.squashfs..."
sudo mksquashfs "$CHROOT_DIR" "$IMAGE_DIR/casper/filesystem.squashfs" -noappend -wildcards -comp xz
printf $(sudo du -sx --block-size=1 "$CHROOT_DIR" | cut -f1) | sudo tee "$IMAGE_DIR/casper/filesystem.size"

cd "$IMAGE_DIR"

# Prepare ISOLINUX BIOS boot files
echo "[3/5] Preparing ISOLINUX BIOS boot files..."
mkdir -p isolinux

# Copy required SYSLINUX BIOS modules
cp /usr/lib/ISOLINUX/isolinux.bin isolinux/
cp /usr/lib/syslinux/modules/bios/ldlinux.c32 isolinux/
cp /usr/lib/syslinux/modules/bios/libcom32.c32 isolinux/
cp /usr/lib/syslinux/modules/bios/vesamenu.c32 isolinux/
cp /usr/lib/syslinux/modules/bios/libutil.c32 isolinux/

# Create isolinux boot catalog
touch isolinux/boot.cat

# Create isolinux.cfg
cat <<EOF | sudo tee isolinux/isolinux.cfg
UI vesamenu.c32
DEFAULT live
PROMPT 0
TIMEOUT 50

MENU TITLE Cloudify OS Boot Menu

LABEL live
    MENU LABEL Try Cloudify OS
    KERNEL /casper/vmlinuz
    APPEND initrd=/casper/initrd boot=casper quiet splash
EOF

# Prepare EFI boot image using grub-mkstandalone
echo "[4/5] Creating EFI boot image..."
mkdir -p iso/EFI/BOOT

# Create a standalone GRUB EFI image
grub-mkstandalone \
    --format=x86_64-efi \
    --output=bootx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=isolinux/isolinux.cfg"

# Create FAT image for EFI boot
dd if=/dev/zero of=efiboot.img bs=1M count=20
mkfs.vfat efiboot.img
mmd -i efiboot.img ::/EFI
mmd -i efiboot.img ::/EFI/BOOT
mcopy -vi efiboot.img bootx64.efi ::/EFI/BOOT/

# Generate the final ISO with EFI + BIOS hybrid boot
echo "[5/5] Generating bootable ISO..."
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

echo ""
echo "✅ ISO created successfully at: $BUILD_DIR/$ISO_NAME"
echo "✅ You can now test using:"
echo ""
echo "qemu-system-x86_64 -m 2048 -cdrom $BUILD_DIR/$ISO_NAME"
echo ""
