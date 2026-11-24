#!/bin/bash

ICON="$HOME/.config/hypr/hyprland/icons/manager/icon.png"
SDDM_DEST="/usr/share/sddm/faces/$(whoami).face.icon"

if [[ ! -f "$ICON" ]]; then
  echo "Error: Source icon not found at $ICON"
  exit 1
fi

# 1. Update SDDM login screen
if sudo cp "$ICON" "$SDDM_DEST" && sudo chmod 644 "$SDDM_DEST"; then
  echo "Icon has successfully changed in Login Screen"
fi

# 2. Update local user face icon
if cp "$ICON" "$HOME/.face"; then
  echo "Icon has successfully changed in Shell"
fi
