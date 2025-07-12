#!/bin/bash
set -e

echo '[2.2.3] Setting up machine ID and initctl diversion...'
dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id

if ! dpkg-divert --list | grep -q /sbin/initctl; then
  dpkg-divert --local --rename --add /sbin/initctl
fi

rm -f /sbin/initctl
ln -s /bin/true /sbin/initctl
