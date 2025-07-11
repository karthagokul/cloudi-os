#!/bin/bash
set -e
BUILD_DIR="$PWD/build"
CHROOT_DIR="$BUILD_DIR/chroot"
IMAGE_DIR="$BUILD_DIR/image"
DISTRIBUTION="noble"
ARCH="amd64"
UBUNTU_MIRROR="http://us.archive.ubuntu.com/ubuntu/"
ISO_NAME="cloudify-os-${DISTRIBUTION}-${ARCH}.iso"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive
echo "--- Cloudify OS Build Environment Loaded ---"
