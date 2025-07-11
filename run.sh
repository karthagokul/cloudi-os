#sudo apt-get update
sudo apt-get install qemu-system-x86 qemu-utils
qemu-system-x86_64 -m 2048 -cdrom build/cloudify-os-noble-amd64.iso -d guest_errors,cpu_reset -D qemu.log

