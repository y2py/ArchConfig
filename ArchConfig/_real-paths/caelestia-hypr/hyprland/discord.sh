#!/bin/bash
if ! pgrep -fi "discord.*canary" > /dev/null; then
    hyprctl dispatch togglespecialworkspace communication
    discord-canary --disable-features=UseOzonePlatform --ozone-platform=x11 &
    sleep 1
else
    hyprctl dispatch togglespecialworkspace communication

fi
