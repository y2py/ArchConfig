#!/bin/bash
folder="$HOME/.config/hypr/hyprland/extra/MouseMicController"
file="$folder/dynamic_color"
echo "$(caelestia scheme get | awk '/term1:/ {print $2}')">$file
echo "Color Changed Sucessfully"
