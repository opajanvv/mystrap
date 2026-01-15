#!/bin/bash
WALLPAPER_DIR=~/Wallpaper
DAILY=$(date +%Y%m%d).jpg  # Unique filename per day
IMG=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n1)

# Resize/fit if needed, save as daily cache
convert "$IMG" -resize 1920x1080 "$HOME/$DAILY"  # Adjust resolution

# Set on ALL monitors
hyprctl hyprpaper preload "$HOME/$DAILY"
hyprctl hyprpaper wallpaper ",$HOME/$DAILY"  # Comma = all monitors [web:20]

rm -f ~/.$DAILY.prev  # Cleanup old
mv "$HOME/$DAILY" ~/.$DAILY.prev 2>/dev/null || true
