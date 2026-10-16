#!/bin/bash
FOLDER="$HOME/.cache/lockScreen"
CURR=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_layout_index')
PREV="$FOLDER/previous"
bash "$HOME/.config/hypr/hyprland/lockscripts/init.sh"

echo "$CURR" > "$PREV"
hyprctl switchxkblayout current 0


