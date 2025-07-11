#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration Variables ---
# Define the base directory for your custom OS build
BUILD_DIR="$PWD/build" # Changed from "$HOME/live-ubuntu-from-scratch" to current directory
CHROOT_DIR="$BUILD_DIR/chroot"
IMAGE_DIR="$BUILD_DIR/image"
DISTRIBUTION="noble" # Ubuntu 24.04 LTS
ARCH="amd64"
UBUNTU_MIRROR="http://us.archive.ubuntu.com/ubuntu/"
ISO_NAME="cloudify-os-${DISTRIBUTION}-${ARCH}.iso"

# Explicitly set a robust PATH for root operations within the script
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Set DEBIAN_FRONTEND to noninteractive to prevent interactive prompts during apt operations
export DEBIAN_FRONTEND=noninteractive

echo "--- Cloudify OS Custom Build Script ---"
echo "Target Distribution: $DISTRIBUTION ($ARCH)"
echo "Build Directory: $BUILD_DIR"
echo "Output ISO: $ISO_NAME"
echo "---------------------------------------"

# --- Step 1: Prepare the Environment ---
echo "[1/10] Installing necessary dependencies on host system..."
sudo apt-get update
sudo apt-get install -y \
   debootstrap \
   squashfs-tools \
   xorriso \
   syslinux-common \
   mtools \
   unzip \
   grub-pc-bin \
   grub-efi-amd64-bin \
   curl \
   wget \
   gnupg \
   apt-transport-https

# Clean up previous build artifacts if they exist
echo "[1/10] Cleaning up previous build directories..."
sudo rm -rf "$CHROOT_DIR" "$IMAGE_DIR" "$BUILD_DIR/$ISO_NAME"
mkdir -p "$CHROOT_DIR"

# --- Step 2: Create a Base System (Bootstrap Ubuntu) ---
echo "[2/10] Bootstrapping minimal Ubuntu system into chroot..."
sudo debootstrap \
   --arch="$ARCH" \
   --variant=minbase \
   "$DISTRIBUTION" \
   "$CHROOT_DIR" \
   "$UBUNTU_MIRROR"

# Configure external mount points for chroot environment
echo "[2/10] Mounting /dev and /run into chroot..."
sudo mount --bind /dev "$CHROOT_DIR/dev"
sudo mount --bind /run "$CHROOT_DIR/run"

# --- Step 3: Define and Customize Chroot Environment ---
echo "[3/10] Entering chroot environment for customization..."

sudo chroot "$CHROOT_DIR" /bin/bash -c "
set -e

# Mount necessary filesystems inside chroot
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts

# Set HOME and LC_ALL for chroot session
export HOME=/root
export LC_ALL=C

# Set a custom hostname
echo 'cloudify-os-live' > /etc/hostname

# Configure apt sources.list
cat <<EOF_APT_SOURCES > /etc/apt/sources.list
deb http://us.archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse
deb http://us.archive.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
deb http://us.archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse
EOF_APT_SOURCES

# Update package indexes
apt-get update

# Install systemd
apt-get install -y libterm-readline-gnu-perl systemd-sysv

# Configure machine-id and divert initctl
dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

# Upgrade packages
apt-get -y upgrade

# Install packages needed for Live System and Graphical Installer
echo '[3/10] Installing core live system and graphical installer packages...'
apt-get install -y sudo ubuntu-standard casper discover laptop-detect os-prober network-manager net-tools wireless-tools wpagui locales grub-common grub-gfxpayload-lists grub-pc grub-pc-bin grub2-common grub-efi-amd64-signed shim-signed mtools binutils ubiquity ubiquity-casper ubiquity-frontend-gtk ubiquity-slideshow-ubuntu ubiquity-ubuntu-artwork

# Install generic Linux kernel
apt-get install -y --no-install-recommends linux-generic

# Install XFCE window manager and themes
echo '[3/10] Installing XFCE desktop environment and themes...'
apt-get install -y xubuntu-desktop plymouth-themes

# Install useful applications
echo '[3/10] Installing useful applications...'
apt-get install -y clamav-daemon terminator curl vim nano less git docker.io docker-compose python3-pip python3-venv build-essential cmake

# Install Visual Studio Code
echo '[3/10] Installing Visual Studio Code...'
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
echo 'deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main' > /etc/apt/sources.list.d/vscode.list
rm microsoft.gpg
apt-get update
apt-get install -y code

# Install Google Chrome
echo '[3/10] Installing Google Chrome...'
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > google.gpg
install -o root -g root -m 644 google.gpg /etc/apt/trusted.gpg.d/
echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/google-chrome.list
rm google.gpg
apt-get update
apt-get install -y google-chrome-stable

# Install Java JDK 8
echo '[3/10] Installing Java JDK 8...'
apt-get install -y openjdk-8-jdk openjdk-8-jre

# Remove unused applications
echo '[3/10] Removing unused applications (optional cleanup)...'
apt-get purge -y transmission-gtk transmission-common gnome-mahjongg gnome-mines gnome-sudoku aisleriot hitori || true

# Autoremove
echo '[3/10] Running apt autoremove...'
apt-get autoremove -y

# Reconfigure locales
echo '[3/10] Reconfiguring locales...'
dpkg-reconfigure --frontend=noninteractive locales

# Configure NetworkManager
echo '[3/10] Configuring NetworkManager...'
cat <<EOF_NM_CONF > /etc/NetworkManager/NetworkManager.conf
[main]
rc-manager=none
plugins=ifupdown,keyfile
dns=systemd-resolved

[ifupdown]
managed=false
EOF_NM_CONF
dpkg-reconfigure --frontend=noninteractive network-manager

# Cleanup
echo '[3/10] Performing chroot cleanup...'
rm -f /etc/machine-id /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl
apt-get clean
rm -rf /tmp/* ~/.bash_history /root/.bash_history

# Unmount filesystems before exiting
umount /proc || true
umount /sys || true
umount /dev/pts || true

export HISTSIZE=0
"

echo "[3/10] Exited chroot environment."


# Unbind mount points from host
echo "[4/10] Unmounting /dev and /run from chroot..."
sudo umount "$CHROOT_DIR/dev"
sudo umount "$CHROOT_DIR/run"

# --- Step 4: Create the image directory and populate it ---
echo "[5/10] Creating image directory structure..."
mkdir -p "$IMAGE_DIR/{casper,isolinux,install}"

# Dynamically find the kernel version
KERNEL_VERSION=$(sudo ls "$CHROOT_DIR/boot" | grep vmlinuz- | sed 's/vmlinuz-//')
echo "[5/10] Detected kernel version: $KERNEL_VERSION"

# Copy kernel images
echo "[5/10] Copying kernel and initrd images..."
sudo cp "$CHROOT_DIR/boot/vmlinuz-$KERNEL_VERSION" "$IMAGE_DIR/casper/vmlinuz"
sudo cp "$CHROOT_DIR/boot/initrd.img-$KERNEL_VERSION" "$IMAGE_DIR/casper/initrd"

# Copy memtest86+ binary (BIOS and UEFI)
echo "[5/10] Downloading and copying Memtest86+ binaries..."
sudo wget --progress=dot https://memtest.org/download/v7.00/mt86plus_7.00.binaries.zip -O "$IMAGE_DIR/install/memtest86.zip"
sudo unzip -p "$IMAGE_DIR/install/memtest86.zip" memtest64.bin | sudo tee "$IMAGE_DIR/install/memtest86+.bin" > /dev/null
sudo unzip -p "$IMAGE_DIR/install/memtest86.zip" memtest64.efi | sudo tee "$IMAGE_DIR/install/memtest86+.efi" > /dev/null
sudo rm -f "$IMAGE_DIR/install/memtest86.zip"

# --- GRUB menu configuration ---
echo "[6/10] Configuring GRUB menu..."
sudo touch "$IMAGE_DIR/ubuntu" # Base point access file for grub

# Create image/isolinux/grub.cfg
sudo bash -c "cat <<EOF_GRUB > \"$IMAGE_DIR/isolinux/grub.cfg\"
search --set=root --file /ubuntu

insmod all_video

set default=\"0\"
set timeout=30

menuentry \"Try Cloudify OS without installing\" {
   linux /casper/vmlinuz boot=casper nopersistent toram quiet splash ---
   initrd /casper/initrd
}

menuentry \"Install Cloudify OS\" {
   linux /casper/vmlinuz boot=casper only-ubiquity quiet splash ---
   initrd /casper/initrd
}

menuentry \"Check disc for defects\" {
   linux /casper/vmlinuz boot=casper integrity-check quiet splash ---
   initrd /casper/initrd
}

grub_platform
if [ \"\$grub_platform\" = \"efi\" ]; then
menuentry 'UEFI Firmware Settings' {
   fwsetup
}

menuentry \"Test memory Memtest86+ (UEFI)\" {
   linux /install/memtest86+.efi
}
else
menuentry \"Test memory Memtest86+ (BIOS)\" {
   linux16 /install/memtest86+.bin
}
fi
EOF_GRUB"

# --- Create manifest ---
echo "[7/10] Generating filesystem manifests..."
sudo dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee "$IMAGE_DIR/casper/filesystem.manifest" > /dev/null
sudo cp -v "$IMAGE_DIR/casper/filesystem.manifest" "$IMAGE_DIR/casper/filesystem.manifest-desktop"
sudo sed -i '/ubiquity/d' "$IMAGE_DIR/casper/filesystem.manifest-desktop"
sudo sed -i '/casper/d' "$IMAGE_DIR/casper/filesystem.manifest-desktop"
sudo sed -i '/discover/d' "$IMAGE_DIR/casper/filesystem.manifest-desktop"
sudo sed -i '/laptop-detect/d' "$IMAGE_DIR/casper/filesystem.manifest-desktop"
sudo sed -i '/os-prober/d' "$IMAGE_DIR/casper/filesystem.manifest-desktop"

# --- Create diskdefines ---
echo "[8/10] Creating README.diskdefines..."
sudo bash -c "cat <<EOF_DISKDEFS > \"$IMAGE_DIR/README.diskdefines\"
#define DISKNAME  Cloudify OS
#define TYPE  binary
#define TYPEbinary  1
#define ARCH  $ARCH
#define ARCHamd64  1
#define DISKNUM  1
#define DISKNUM1  1
#define TOTALNUM  0
#define TOTALNUM0  1
EOF_DISKDEFS"

# --- Creating bootloaders and images for ISO ---
echo "[9/10] Creating EFI/BIOS bootloaders and images..."
(
    cd "$IMAGE_DIR" || exit 1 # Exit if cd fails
    # Copy EFI loaders
    sudo cp "/usr/lib/shim/shimx64.efi.signed.previous" isolinux/bootx64.efi
    sudo cp "/usr/lib/shim/mmx64.efi" isolinux/mmx64.efi
    sudo cp "/usr/lib/grub/x86_64-efi-signed/grubx64.efi.signed" isolinux/grubx64.efi

    # Create a FAT16 UEFI boot disk image
    echo "  Creating efiboot.img..."
    dd if=/dev/zero of=isolinux/efiboot.img bs=1M count=10
    sudo mkfs.vfat -F 16 isolinux/efiboot.img
    LC_CTYPE=C sudo mmd -i isolinux/efiboot.img efi efi/ubuntu efi/boot
    LC_CTYPE=C sudo mcopy -i isolinux/efiboot.img ./isolinux/bootx64.efi ::efi/boot/bootx64.efi
    LC_CTYPE=C sudo mcopy -i isolinux/efiboot.img ./isolinux/mmx64.efi ::efi/boot/mmx64.efi
    LC_CTYPE=C sudo mcopy -i isolinux/efiboot.img ./isolinux/grubx64.efi ::efi/boot/grubx64.efi
    LC_CTYPE=C sudo mcopy -i isolinux/efiboot.img ./isolinux/grub.cfg ::efi/ubuntu/grub.cfg

    # Create a grub BIOS image
    echo "  Creating BIOS boot image..."
    sudo grub-mkstandalone \
       --format=i386-pc \
       --output=isolinux/core.img \
       --install-modules="linux16 linux normal iso9660 biosdisk memdisk search tar ls" \
       --modules="linux16 linux normal iso9660 biosdisk search" \
       --locales="" \
       --fonts="" \
       "boot/grub/grub.cfg=isolinux/grub.cfg"

    # Combine a bootable Grub cdboot.img
    sudo cat "/usr/lib/grub/i386-pc/cdboot.img" isolinux/core.img > isolinux/bios.img

    # Generate md5sum.txt (excluding isolinux directory contents)
    echo "  Generating md5sum.txt..."
    sudo /bin/bash -c "(find . -type f -print0 | xargs -0 md5sum | grep -v -e 'isolinux' > md5sum.txt)"
)

# --- Compress the chroot ---
echo "[10/10] Compressing chroot filesystem (this will take a while)..."
# Move image artifacts to the root of the build directory for mksquashfs
# The README's mv chroot/image . is confusing; assuming image is already outside chroot
# and we are creating filesystem.squashfs from the chroot itself.
sudo mksquashfs "$CHROOT_DIR" "$IMAGE_DIR/casper/filesystem.squashfs" \
   -noappend -no-duplicates -no-recovery \
   -wildcards \
   -comp xz -b 1M -Xdict-size 100% \
   -e "var/cache/apt/archives/*" \
   -e "root/*" \
   -e "root/.*" \
   -e "tmp/*" \
   -e "tmp/.*" \
   -e "swapfile"

# Write the filesystem.size
echo "[10/10] Writing filesystem.size..."
printf $(sudo du -sx --block-size=1 "$CHROOT_DIR" | cut -f1) | sudo tee "$IMAGE_DIR/casper/filesystem.size" > /dev/null

# --- Create ISO Image (Alternative way, Hybrid ISO) ---
echo "[10/10] Creating final ISO image (this will take a while)..."
(
    cd "$IMAGE_DIR" || exit 1 # Exit if cd fails

    # Create ISOLINUX (syslinux) boot menu
    echo "  Creating isolinux/isolinux.cfg..."
    sudo bash -c "cat <<'EOF_ISOLINUX' > isolinux/isolinux.cfg
UI vesamenu.c32

MENU TITLE Boot Menu
DEFAULT linux
TIMEOUT 600
MENU RESOLUTION 640 480
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

LABEL linux
 MENU LABEL Try Cloudify OS
 MENU DEFAULT
 KERNEL /casper/vmlinuz
 APPEND initrd=/casper/initrd boot=casper

LABEL linux-nomodeset
 MENU LABEL Try Cloudify OS (nomodeset)
 KERNEL /casper/vmlinuz
 APPEND initrd=/casper/initrd boot=casper nomodeset
EOF_ISOLINUX"

    # Include syslinux bios modules
    echo "  Copying syslinux BIOS modules..."
    sudo cp "/usr/lib/syslinux/modules/bios/vesamenu.c32" isolinux/
    sudo cp "/usr/lib/syslinux/modules/bios/menu.c32" isolinux/
    sudo cp "/usr/lib/syslinux/modules/bios/ldlinux.c32" isolinux/
    sudo cp "/usr/lib/syslinux/modules/bios/libutil.c32" isolinux/
    sudo cp "/usr/lib/syslinux/modules/bios/libmenu.c32" isolinux/
    sudo cp "/usr/lib/syslinux/modules/bios/libcom32.c32" isolinux/
    sudo cp "/usr/lib/syslinux/modules/bios/chain.c32" isolinux/ # Often needed
    sudo cp "/usr/lib/syslinux/modules/bios/reboot.c32" isolinux/ # Often needed
    sudo cp "/usr/lib/syslinux/modules/bios/hwdetect.c32" isolinux/ # Often needed
    sudo cp "/usr/lib/syslinux/modules/bios/ifcpu64.c32" isolinux/ # Often needed for 64-bit

    # Create isolinux.bin
    sudo cp "/usr/lib/ISOLINUX/isolinux.bin" isolinux/

    # Create iso from the image directory
    echo "  Running xorriso to create the final ISO..."
    sudo xorriso \
      -as mkisofs \
      -iso-level 3 \
      -full-iso9660-filenames \
      -J -J -joliet-long \
      -volid "Cloudify OS" \
      -output "../$ISO_NAME" \
      -isohybrid-mbr "/usr/lib/ISOLINUX/isohdpfx.bin" \
      -eltorito-boot \
          "isolinux/isolinux.bin" \
          -no-emul-boot \
          -boot-load-size 4 \
          -boot-info-table \
          --eltorito-catalog "isolinux/isolinux.cat" \
      -eltorito-alt-boot \
          -e "/EFI/boot/efiboot.img" \
          -no-emul-boot \
          -isohybrid-gpt-basdat \
      -append_partition 2 0xef "EFI/boot/efiboot.img" \
      . # This '.' means include all files in the current directory ($IMAGE_DIR)
)

echo "---------------------------------------"
echo "Build process completed! Your ISO is located at: $BUILD_DIR/$ISO_NAME"
echo "---------------------------------------"
