#!/bin/sh
# Stops the mpv screensaver

PID_FILE="$HOME/.cache/screensaver.pid"

# Kill screensaver if running
if [ -f "$PID_FILE" ]; then
    /usr/bin/kill "$(/usr/bin/cat "$PID_FILE")" 2>/dev/null || true
    /usr/bin/rm -f "$PID_FILE"
fi

# Also kill any lingering mpv instances from screensaver
/usr/bin/pkill -f "mpv --fullscreen.*image-display-duration" 2>/dev/null || true
