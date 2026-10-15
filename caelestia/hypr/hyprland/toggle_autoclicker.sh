#!/bin/bash
ICON="$HOME/.config/hypr/hyprland/icons/manager/icon.png"
SOUNDS_FOLDER="$HOME/.config/hypr/hyprland/sounds"
CLICKER_FOLDER="$SOUNDS_FOLDER/clicker"
ON_SOUND="$CLICKER_FOLDER/on.mp3"
OFF_SOUND="$CLICKER_FOLDER/off.mp3"
PID_FILE="/tmp/autoclicker.pid"
SPEED=0.01

if [[ -f "$PID_FILE" ]]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null
    rm "$PID_FILE"
    pw-play "$OFF_SOUND" &
    notify-send -i $ICON "System Message" "Auto Clicker Stopped!"
else
    ydotool key 125:0
    while true; do ydotool click 0xC0 >/dev/null; sleep $SPEED; done &
    echo $! > "$PID_FILE"
    pw-play "$ON_SOUND" &
    notify-send -i $ICON "System Message" "Auto Clicker Started!"
fi
