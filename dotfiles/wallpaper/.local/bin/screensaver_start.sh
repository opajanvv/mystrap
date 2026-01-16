#!/bin/sh
# Starts a wallpaper slideshow as screensaver
# Runs in background, changing images every INTERVAL seconds
set -eu

WALLPAPER_DIR="$HOME/Wallpaper"
PID_FILE="$HOME/.cache/screensaver.pid"
INTERVAL=10  # seconds between wallpaper changes

# Kill any existing slideshow
if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null || true
    rm -f "$PID_FILE"
fi

# Get all images
IMAGES=$(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \))
COUNT=$(echo "$IMAGES" | wc -l)

[ "$COUNT" -eq 0 ] && exit 1

# Start slideshow in background
(
    while true; do
        # Get monitor names from swww
        MONITORS=$(swww query | cut -d: -f1)

        for monitor in $MONITORS; do
            # Pick random image for each monitor (different per monitor)
            IMG=$(echo "$IMAGES" | shuf -n1)
            swww img "$IMG" --outputs "$monitor" \
                --transition-type fade --transition-duration 0.5 \
                2>/dev/null || true
        done

        sleep "$INTERVAL"
    done
) &

# Save PID for cleanup
echo $! > "$PID_FILE"
