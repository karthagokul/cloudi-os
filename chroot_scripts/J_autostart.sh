#!/bin/bash
set -e

echo '[2.2.12] Enabling Plank dock autostart...'

mkdir -p /home/ubuntu/.config/autostart
cat <<EOF > /home/ubuntu/.config/autostart/plank.desktop
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank
EOF

chown -R ubuntu:ubuntu /home/ubuntu/.config

# Prevent accidental host panel interference
if [[ "$CHROOT_ENV" == "true" ]]; then
  echo '[i] Removing bottom panel if it exists (inside chroot)...'
  sudo -u ubuntu xfconf-query -c xfce4-panel -p /panels -a | grep -q '2' && \
    sudo -u ubuntu xfconf-query -c xfce4-panel -p /panels -t int -s 2 -n && \
    sudo -u ubuntu xfconf-query -c xfce4-panel -p /panels -r -R || true
else
  echo '[i] Skipping xfce4-panel changes on host.'
fi
