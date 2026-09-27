#!/bin/bash
if ! pgrep -fi "discord*" > /dev/null; then
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("communication")'
    prime-run discord & 
    sleep 1
else
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("communication")'
fi
