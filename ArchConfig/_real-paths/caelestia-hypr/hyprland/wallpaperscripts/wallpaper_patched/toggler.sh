#!/bin/bash

STATE=$(echo '{ "command": ["get_property", "pause"] }' | socat - /tmp/mpvpaper.sock | jq -r '.data')

if [ "$STATE" = "true" ]; then
    echo '{ "command": ["set_property", "pause", false] }' | socat - /tmp/mpvpaper.sock
else
    echo '{ "command": ["set_property", "pause", true] }' | socat - /tmp/mpvpaper.sock
fi
