#!/bin/bash


wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "[MUTED]"; then
    pw-play ~/.config/hypr/hyprland/sounds/mic/mute.mp3 &
    openrgb --color FF0000 &
else

    pw-play ~/.config/hypr/hyprland/sounds/mic/unmute.mp3 &
    openrgb --color 00FF00 &
    
fi
