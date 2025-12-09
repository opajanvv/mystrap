#!/bin/sh
# helpers.sh - Utility functions for Phoenix bootstrap scripts
# POSIX sh compatible utilities

set -eu

# Logging utilities
log() {
    echo "[INFO] $*"
}

warn() {
    echo "[WARN] $*" >&2
}

die() {
    echo "[ERROR] $*" >&2
    exit 1
}
