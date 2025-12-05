#!/bin/sh
# Post-install script for cronie
# Enables and starts the cronie service (cron daemon)

set -eu

# Enable service if not already enabled
if ! systemctl is-enabled cronie.service >/dev/null 2>&1; then
    sudo systemctl enable cronie.service
fi

# Start service if not already running
if ! systemctl is-active cronie.service >/dev/null 2>&1; then
    sudo systemctl start cronie.service
fi
