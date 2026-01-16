#!/bin/sh
# Starts a fullscreen mpv slideshow as screensaver
# Covers all windows and waybar

WALLPAPER_DIR="$HOME/Wallpaper"
PID_FILE="$HOME/.cache/screensaver.pid"

# Kill any existing screensaver
if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null || true
    rm -f "$PID_FILE"
fi

# Launch mpv fullscreen slideshow
# --fullscreen: covers everything
# --loop-playlist: loop forever
# --image-display-duration=10: show each image for 10 seconds
# --shuffle: randomize order
# --no-input-default-bindings: disable most keys (we'll kill on any input via hypridle)
# --input-conf=/dev/null: no input config
# --no-osc: no on-screen controller
# --no-osd-bar: no progress bar
mpv --fullscreen \
    --loop-playlist \
    --image-display-duration=10 \
    --shuffle \
    --no-input-default-bindings \
    --input-conf=/dev/null \
    --no-osc \
    --no-osd-bar \
    --really-quiet \
    "$WALLPAPER_DIR"/* &

echo $! > "$PID_FILE"
