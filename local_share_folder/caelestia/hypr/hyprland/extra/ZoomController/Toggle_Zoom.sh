#!/bin/bash

SOUNDS_FOLDER="$HOME/.config/hypr/hyprland/sounds"
ZOOM_FOLDER="$SOUNDS_FOLDER/zoom"

ON_SOUND="$ZOOM_FOLDER/zoom_in.mp3"
OFF_SOUND="$ZOOM_FOLDER/zoom_out.mp3"

STATE_FILE="/tmp/zoom.state"
SPEED=0.01

if [[ -f "$STATE_FILE" ]]; then
  hyprctl eval "hl.config({ cursor = { zoom_factor = 1.0 }})"

  rm -f "$STATE_FILE"

  pw-play "$OFF_SOUND" &

else
  hyprctl eval "hl.config({ cursor = { zoom_factor = ${1:-2.0} }})"

  touch "$STATE_FILE"

  pw-play "$ON_SOUND" &
fi
