#!/bin/bash
set -e

echo '[2.2.10] Disabling unneeded services...'
systemctl disable bluetooth avahi-daemon ModemManager cups apport || true
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target || true

echo '[2.2.10] Enabling LightDM display manager and NetworkManager...'

systemctl enable lightdm
systemctl enable NetworkManager