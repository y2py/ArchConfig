#!/bin/bash
caelestia shell -d
bash ~/.config/hypr/hyprland/idlescripts/restore-idle-state.sh &
disown
bash ~/.config/hypr/hyprland/force_dark_mode.sh &
disown
pkill -f "caelestia wallpaper"
rm -f ~/.local/state/caelestia/theme.lock
