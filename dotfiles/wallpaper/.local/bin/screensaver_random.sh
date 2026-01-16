#!/bin/bash
WALLPAPER_DIR=~/Wallpaper

# Get all monitor names
MONITORS=($(hyprctl monitors -j | jq -r '.[].name'))

for monitor in "${MONITORS[@]}"; do
    IMG=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n1)
    hyprctl hyprpaper preload "$IMG"
    hyprctl hyprpaper wallpaper "$monitor,$IMG"
done
