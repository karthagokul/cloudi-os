#!/bin/bash
set -e

echo '[2.2.12] Cleaning up XFCE panels (keep only Plank dock)...'

# Kill existing panel and plank (just in case)
pkill xfce4-panel || true
pkill plank || true

# Remove default XFCE panels
rm -rf /home/ubuntu/.config/xfce4/panel
mkdir -p /home/ubuntu/.config/autostart

# Autostart only Plank
cat <<EOF > /home/ubuntu/.config/autostart/plank.desktop
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Plank
EOF

# Restart Plank only
sudo -u ubuntu plank &

# Ensure correct ownership
chown -R ubuntu:ubuntu /home/ubuntu/.config

echo '[2.2.12] XFCE panel removed, only Plank remains.'


echo '[2.2.13] Final cleanup...'
locale-gen
update-locale LANG=en_US.UTF-8
apt-get autoremove -y
apt-get clean
rm -rf /tmp/*
