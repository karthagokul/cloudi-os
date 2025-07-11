#!/bin/bash
sudo apt install xorriso genisoimage live-build
sudo lb clean --all
sudo lb config \
  --distribution noble \
  --binary-images iso-hybrid \
  --debian-installer live \
  --archive-areas "main restricted universe multiverse" \
  --mirror-bootstrap http://archive.ubuntu.com/ubuntu/ \
  --mirror-binary http://archive.ubuntu.com/ubuntu/ \
  --mode ubuntu
sudo lb build
