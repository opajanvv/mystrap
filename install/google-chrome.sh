#!/bin/sh
# Post-install script for google-chrome
# Sets Chrome as the default web browser and configures xdg-mime associations

set -eu

# Set Chrome as default browser using xdg-settings
xdg-settings set default-web-browser google-chrome.desktop

# Set xdg-mime associations for common web MIME types
xdg-mime default google-chrome.desktop text/html
xdg-mime default google-chrome.desktop application/xhtml+xml
xdg-mime default google-chrome.desktop x-scheme-handler/http
xdg-mime default google-chrome.desktop x-scheme-handler/https
