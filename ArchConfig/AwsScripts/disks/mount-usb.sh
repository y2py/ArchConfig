#!/bin/bash

DEVICE="/dev/sda3"
MOUNT_POINT="/run/media/$USER/Lexar"

if [ -b "$DEVICE" ]; then
    echo "Device found"

    if ! mount | grep -q "$DEVICE"; then
        udisksctl mount -b "$DEVICE"
    else
        echo "Already mounted"
    fi
else
    echo "Device not connected"
fi
