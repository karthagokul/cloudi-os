#!/bin/bash
set -e
echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
echo '[2.2.7] Enabling LightDM autologin...'
mkdir -p /etc/lightdm/lightdm.conf.d
cat <<EOF > /etc/lightdm/lightdm.conf.d/50-cloudify-autologin.conf
[Seat:*]
autologin-user=ubuntu
autologin-user-timeout=0
EOF

echo '[2.2.8] Setting NetworkManager configuration...'
cat <<EOF > /etc/NetworkManager/NetworkManager.conf
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=true
EOF
