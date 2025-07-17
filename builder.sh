#!/bin/bash

set -e

ACTION=$1
MODE=${2:-dev}  # Default to dev mode if not specified

ISO_NAME="build/cloudify-os-noble-amd64.iso"
SKIP_COMPRESSION=true  # Default: dev mode skips compression

if [[ "$MODE" == "release" ]]; then
    SKIP_COMPRESSION=false
    echo " Release mode enabled — compression will be used"
else
    echo "  Developer mode — skipping compression"
fi

if [ -z "$ACTION" ]; then
    echo "Usage: $0 [prepare|build|deploy|all|debug] [dev|release]"
    exit 1
fi

function build_image() {
    echo " Building Docker image..."
    docker build -t cloudi-os-builder .
}

function run_ansible() {
    echo " Running Ansible playbook (SKIP_COMPRESSION=$SKIP_COMPRESSION)..."
    docker run -it --privileged --rm -v "$(pwd):/workspace" -v /dev:/dev cloudi-os-builder \
        ansible-playbook playbook.yml -e "SKIP_COMPRESSION=$SKIP_COMPRESSION"
}

function deploy_iso() {
    echo "Launching ISO with QEMU..."
    if [ ! -f "$ISO_NAME" ]; then
        echo " ISO not found at $ISO_NAME"
        exit 1
    fi
    qemu-system-x86_64 -m 2048 -cdrom "$ISO_NAME" -serial mon:stdio
}

function debug_shell() {
    echo " Entering Docker debug shell..."
    docker run -it --privileged --rm -v "$(pwd):/workspace" -v /dev:/dev cloudi-os-builder /bin/bash
}

case "$ACTION" in
    prepare)
        build_image
        ;;
    build)
        build_image
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
        echo " Invalid action: $ACTION"
        echo "Usage: $0 [build|run|deploy|all|debug] [dev|release]"
        exit 1
        ;;
esac
