#!/bin/sh
# Sets a deterministic daily wallpaper based on date
set -eu

WALLPAPER_DIR="$HOME/Wallpaper"
CACHE_FILE="$HOME/.cache/daily_wallpaper"

# Get all images sorted (for deterministic ordering)
IMAGES=$(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | sort)
COUNT=$(echo "$IMAGES" | wc -l)

if [ "$COUNT" -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPER_DIR" >&2
    exit 1
fi

# Use date as seed for deterministic daily selection
DAY_NUM=$(date +%j)  # Day of year (1-366)
YEAR=$(date +%Y)
INDEX=$(( (DAY_NUM + YEAR) % COUNT + 1 ))
IMG=$(echo "$IMAGES" | sed -n "${INDEX}p")

# Set wallpaper on all monitors with a fade transition
swww img "$IMG" --transition-type fade --transition-duration 1

# Cache current wallpaper path for restore after screensaver
mkdir -p "$(dirname "$CACHE_FILE")"
echo "$IMG" > "$CACHE_FILE"
