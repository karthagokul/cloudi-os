#!/bin/bash
set -e

export HOME=/root
export LC_ALL=C
export DISTRIBUTION=${DISTRIBUTION:-jammy}

# Function to mount if not already mounted
mount_if_needed() {
  local target=$1
  local type=$2

  if ! mountpoint -q "$target"; then
    echo "Mounting $target..."
    mount none -t "$type" "$target"
  else
    echo "$target already mounted, skipping..."
  fi
}

# Mount required virtual filesystems
mount_if_needed /proc proc
mount_if_needed /sys sysfs
mount_if_needed /dev/pts devpts

# Run modular scripts inside chroot
for script in /root/chroot_scripts/*.sh; do
  [[ "$(basename "$script")" == "chroot_configure.sh" ]] && continue
  echo "[CHROOT] Running $(basename "$script")"
  chroot "$CHROOT_PATH" /bin/bash -c "export CHROOT_ENV=true; unset DISPLAY; unset XAUTHORITY; bash /root/chroot_scripts/$(basename "$script")"
done



# Cleanup
umount /dev/pts || true
umount /sys || true
umount /proc || true
