#!/bin/bash
set -e

echo '[2.2.4] Preseeding keyboard and locale...'

# Install locales package if not already present
apt-get update
apt-get install -y locales

# Keyboard settings
debconf-set-selections <<< 'keyboard-configuration  keyboard-configuration/layoutcode select us'
debconf-set-selections <<< 'keyboard-configuration  keyboard-configuration/modelcode select pc105'
debconf-set-selections <<< 'keyboard-configuration  keyboard-configuration/xkb-keymap select us'
debconf-set-selections <<< 'keyboard-configuration  keyboard-configuration/layout select USA'

# Locale settings
debconf-set-selections <<< "locales locales/default_environment_locale select en_US.UTF-8"
debconf-set-selections <<< "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8"

# Generate and apply locale
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8
