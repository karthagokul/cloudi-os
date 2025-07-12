#!/bin/bash
set -e

echo '[2.2.9] Optimizing initramfs for faster boot...'
sed -i 's/^MODULES=.*/MODULES=dep/' /etc/initramfs-tools/initramfs.conf
sed -i 's/^COMPRESS=.*/COMPRESS=zstd/' /etc/initramfs-tools/initramfs.conf || echo 'COMPRESS=zstd' >> /etc/initramfs-tools/initramfs.conf
sed -i 's/^MODULES=.*/MODULES=most/' /etc/initramfs-tools/initramfs.conf || echo 'MODULES=most' >> /etc/initramfs-tools/initramfs.conf
update-initramfs -u
