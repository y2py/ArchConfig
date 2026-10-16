#!/bin/bash

red_color="FF0000"
green_color="00FF00"
dynamic_file="$HOME/.config/hypr/hyprland/extra/MouseMicController/dynamic_color"
dynamic=$green_color
if [ -s "$dynamic_file" ]; then
    dynamic=$(cat $dynamic_file | sed 's/\x1b\[[0-9;]*m//g') 
fi



wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "[MUTED]"; then
    pw-play ~/.config/hypr/hyprland/sounds/mic/mute.mp3 &
    gloriousctl --set-effect single --set-colors $red_color --set-brightness 4 >/dev/null 2>&1
else

    pw-play ~/.config/hypr/hyprland/sounds/mic/unmute.mp3 &
    gloriousctl --set-effect single --set-colors $dynamic --set-brightness 4 >/dev/null 2>&1
    
fi
