FROM ubuntu:24.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    ansible \
    sudo \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    grub-common \
    dosfstools \
    grub2-common \
    rsync \
    git \
    systemd-sysv \
    && apt-get clean

# Create ansible user (optional)
RUN useradd -m ansible && echo "ansible ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set workdir
WORKDIR /workspace
COPY . /workspace/

# Default command
CMD [ "bash" ]

