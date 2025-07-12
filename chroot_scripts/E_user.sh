#!/bin/bash
set -e

echo '[2.2.6] Creating user ubuntu with passwordless sudo...'

if ! id "ubuntu" &>/dev/null; then
  useradd -m -s /bin/bash ubuntu
  echo "ubuntu:ubuntu" | chpasswd

  # Add user to essential groups
  for group in sudo adm netdev audio video; do
    adduser ubuntu "$group"
  done
fi

# Create and set up runtime dir
mkdir -p /run/user/1000
chown ubuntu:ubuntu /run/user/1000

# Export runtime dir
echo 'export XDG_RUNTIME_DIR=/run/user/1000' >> /home/ubuntu/.profile

# LightDM autologin setup
mkdir -p /etc/lightdm/lightdm.conf.d
cat <<EOF > /etc/lightdm/lightdm.conf.d/50-autologin.conf
[Seat:*]
autologin-user=ubuntu
autologin-session=xfce
EOF
