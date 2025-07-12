ansible-playbook playbook.yml --ask-become-pass

qemu-system-x86_64   -m 2048   -cdrom build/cloudify-os-noble-amd64.iso   -serial mon:stdio 
