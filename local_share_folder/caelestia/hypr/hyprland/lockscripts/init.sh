#!/bin/bash
TARGET_DIR="$HOME/.cache/lockScreen"

if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"

    if [ ! -f "$TARGET_DIR/previous" ]; then
         echo $(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_layout_index') > "$TARGET_DIR/previous"
    fi

    exit 1
fi

exit 0
