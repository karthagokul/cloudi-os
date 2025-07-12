#!/bin/bash
set -e

echo "[10] Setting up default XFCE session for user..."

USERNAME=ubuntu

# Ensure .xsession file to start XFCE
echo "xfce4-session" > "/home/$USERNAME/.xsession"
chown "$USERNAME:$USERNAME" "/home/$USERNAME/.xsession"
chmod +x "/home/$USERNAME/.xsession"

# Create .dmrc to tell LightDM to use XFCE
mkdir -p "/home/$USERNAME/.config"
cat <<EOF > "/home/$USERNAME/.dmrc"
[Desktop]
Session=xfce
EOF
chown "$USERNAME:$USERNAME" "/home/$USERNAME/.dmrc"
chmod 644 "/home/$USERNAME/.dmrc"

# Ensure LightDM is set as the default display manager
echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager

# Extra: verify session is available
if [ ! -f /usr/share/xsessions/xfce.desktop ]; then
    echo "[WARNING] xfce.desktop session not found! Trying to install xfce4-session..."
    apt-get install -y xfce4-session
fi

# Ensure DBUS session starts correctly
echo 'export $(dbus-launch)' >> /home/ubuntu/.profile


echo "[✔] XFCE session setup complete for user: $USERNAME"
