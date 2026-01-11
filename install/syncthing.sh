#!/bin/sh
# Enable syncthing user service
set -eu

# Enable for current user (runs as user service, not system)
systemctl --user enable syncthing

# Start if not already running
systemctl --user is-active syncthing >/dev/null 2>&1 || systemctl --user start syncthing
