#!/bin/bash
set -e
set -x  # Enable debug output

echo '[2.2.11] Applying macOS WhiteSur look and feel...'

# Ensure necessary packages
apt-get install -y git

# Theme and icon directories
mkdir -p /usr/share/themes /usr/share/icons
mkdir -p /opt
cd /opt

# Clean up if re-running
rm -rf WhiteSur-gtk-theme WhiteSur-icon-theme

# Install GTK Theme
if git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git; then
    cd WhiteSur-gtk-theme
    ./install.sh -d /usr/share/themes -c Dark -t xfwm --normal --round || echo "⚠️ GTK theme install script failed"
    cd ..
    rm -rf WhiteSur-gtk-theme
else
    echo "❌ Failed to clone WhiteSur GTK theme repo"
    exit 1
fi

# Install Icon Theme
if git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git; then
    cd WhiteSur-icon-theme
    ./install.sh -d /usr/share/icons || echo "⚠️ Icon theme install script failed"
    cd ..
    rm -rf WhiteSur-icon-theme
else
    echo "❌ Failed to clone WhiteSur Icon theme repo"
    exit 1
fi

# XFCE Settings (preferred way via xfconf)
sudo -u ubuntu xfconf-query -c xsettings -p /Net/ThemeName -s "WhiteSur-Dark" --create -t string || true
sudo -u ubuntu xfconf-query -c xsettings -p /Net/IconThemeName -s "WhiteSur-dark" --create -t string || true
sudo -u ubuntu xfconf-query -c xsettings -p /Net/CursorThemeName -s "Adwaita" --create -t string || true

# Prevent session from resetting the theme
mkdir -p /home/ubuntu/.config/xfce4/xfce4-session
cat <<EOF > /home/ubuntu/.config/xfce4/xfce4-session/xfce4-session.xml
<?xml version="1.0" encoding="UTF-8"?>
<xfce4-session>
  <property name="SaveOnExit" type="bool" value="false"/>
</xfce4-session>
EOF

# Set ownership
chown -R ubuntu:ubuntu /home/ubuntu/.config

echo '[2.2.11] macOS-like theme applied successfully 🎉'
