#!/bin/bash

FOLDER="$HOME/.cache/lockScreen"
PREV="$FOLDER/previous"
bash "$HOME/.config/hypr/hyprland/lockscripts/init.sh" || exit 0

hyprctl switchxkblayout current "$(cat "$PREV")"
