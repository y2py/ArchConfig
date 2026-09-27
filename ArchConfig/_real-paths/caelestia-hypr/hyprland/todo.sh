#!/bin/bash
if ! pgrep -x "todoist" > /dev/null; then
    todoist &
    sleep 2 
fi
hyprctl dispatch togglespecialworkspace todo

