#!/bin/bash

set -e

# Default values
ACTION=$1
ISO_NAME="build/cloudify-os-noble-amd64.iso"

if [ -z "$ACTION" ]; then
    echo "Usage: $0 [build|run|deploy|all|debug]"
    exit 1
fi

function build_image() {
    echo "Building Docker image..."
    docker build -t cloudi-os-builder .
}

function run_ansible() {
    echo "Running Ansible inside Docker..."
    docker run -it --privileged --rm -v "$(pwd):/workspace" -v /dev:/dev cloudi-os-builder ansible-playbook playbook.yml
}

function deploy_iso() {
    echo "Launching ISO with QEMU..."
    if [ ! -f "$ISO_NAME" ]; then
        echo "ISO not found at $ISO_NAME"
        exit 1
    fi
    qemu-system-x86_64 -m 2048 -cdrom "$ISO_NAME" -serial mon:stdio
}

function debug_shell() {
    echo "🔧 Entering Docker debug mode (interactive shell)..."
    docker run -it --privileged --rm -v "$(pwd):/workspace" -v /dev:/dev cloudi-os-builder /bin/bash
}

case "$ACTION" in
    build)
        build_image
        ;;
    run)
        run_ansible
        ;;
    deploy)
        deploy_iso
        ;;
    all)
        build_image
        run_ansible
        deploy_iso
        ;;
    debug)
        debug_shell
        ;;
    *)
        echo "Invalid action: $ACTION"
        echo "Usage: $0 [build|run|deploy|all|debug]"
        exit 1
        ;;
esac
