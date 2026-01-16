#!/bin/sh
# Stops the wallpaper slideshow and restores daily wallpaper
set -eu

PID_FILE="$HOME/.cache/screensaver.pid"
CACHE_FILE="$HOME/.cache/daily_wallpaper"

# Kill slideshow if running
if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null || true
    rm -f "$PID_FILE"
fi

# Restore daily wallpaper
if [ -f "$CACHE_FILE" ]; then
    IMG=$(cat "$CACHE_FILE")
    swww img "$IMG" --transition-type fade --transition-duration 0.5 2>/dev/null || true
fi
