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

# Create input config that quits on click or keypress
# mpv dismisses itself - hypridle's on-resume can't be used (window creation triggers resume)
INPUT_CONF="$HOME/.cache/screensaver-input.conf"
cat > "$INPUT_CONF" << 'EOF'
MOUSE_BTN0 quit
MOUSE_BTN1 quit
MOUSE_BTN2 quit
ANY_UNICODE quit
ESC quit
EOF

/usr/bin/mpv --fullscreen \
    --loop-playlist \
    --image-display-duration=10 \
    --shuffle \
    --no-osc \
    --no-osd-bar \
    --really-quiet \
    --input-conf="$INPUT_CONF" \
    "$WALLPAPER_DIR"/* &

echo $! > "$PID_FILE"
