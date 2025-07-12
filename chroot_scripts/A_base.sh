#!/bin/bash
set -e

echo '[2.2.1] Setting hostname and sources...'
echo 'cloudify-os-live' > /etc/hostname
echo "deb http://archive.ubuntu.com/ubuntu/ $DISTRIBUTION main restricted universe multiverse" > /etc/apt/sources.list

echo '[2.2.2] Installing base system essentials...'
apt-get update
apt-get install -y systemd-sysv
apt-get upgrade -y
