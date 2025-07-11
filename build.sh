#!/bin/bash
set -e

# Build state file path
BUILD_STATE_FILE="$PWD/.cloudify_build_state"

# Initialize state file if not exists
if [ ! -f "$BUILD_STATE_FILE" ]; then
    echo "STEP_1=pending" > "$BUILD_STATE_FILE"
    echo "STEP_2=pending" >> "$BUILD_STATE_FILE"
    echo "STEP_3=pending" >> "$BUILD_STATE_FILE"
    echo "STEP_4=pending" >> "$BUILD_STATE_FILE"
fi

# Load current state
source "$BUILD_STATE_FILE"

# === HERE is your missing function ===
mark_step_done() {
    local step="$1"
    sed -i "s/^${step}=.*/${step}=done/" "$BUILD_STATE_FILE"
}

echo "=== Cloudify OS Automated Build ==="

if [ "$STEP_1" != "done" ]; then
    ./script_1_prepare_environment.sh
    mark_step_done "STEP_1"
else
    echo "[SKIP] Step 1 already completed."
fi

if [ "$STEP_2" != "done" ]; then
    ./script_2_customize_chroot.sh
    mark_step_done "STEP_2"
else
    echo "[SKIP] Step 2 already completed."
fi

if [ "$STEP_3" != "done" ]; then
    ./script_3_prepare_image_structure.sh
    mark_step_done "STEP_3"
else
    echo "[SKIP] Step 3 already completed."
fi

if [ "$STEP_4" != "done" ]; then
    ./script_4_generate_iso.sh
    mark_step_done "STEP_4"
else
    echo "[SKIP] Step 4 already completed."
fi

echo "=== Build process completed ==="
