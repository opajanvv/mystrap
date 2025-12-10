#!/bin/sh
# Post-install script for orca-slicer-bin
# Creates custom desktop launcher with GDK_SCALE=1 to fix display scaling issues
# Reference: https://opa.janvv.nl/blog/2025-11-16-omarchy-orcaslicer

set -eu

# Source helpers for logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../scripts/helpers.sh" 2>/dev/null || . "$(dirname "$SCRIPT_DIR")/scripts/helpers.sh"

# Desktop launcher path
LAUNCHER_DIR="$HOME/.local/share/applications"
LAUNCHER_FILE="$LAUNCHER_DIR/OrcaSlicer.desktop"

# Expected launcher content
EXPECTED_EXEC="env GDK_SCALE=1 /opt/orca-slicer/bin/orca-slicer %F"

# Check if launcher already exists with correct configuration
if [ -f "$LAUNCHER_FILE" ]; then
    if grep -qF "$EXPECTED_EXEC" "$LAUNCHER_FILE" 2>/dev/null; then
        log "Custom OrcaSlicer launcher already configured correctly"
        exit 0
    else
        log "Existing launcher found but needs updating"
    fi
else
    log "Creating custom OrcaSlicer launcher"
fi

# Create launcher directory if it doesn't exist
if [ ! -d "$LAUNCHER_DIR" ]; then
    log "Creating directory: $LAUNCHER_DIR"
    mkdir -p "$LAUNCHER_DIR"
fi

# Create custom desktop launcher with GDK_SCALE=1 fix
log "Writing custom launcher to $LAUNCHER_FILE"
cat > "$LAUNCHER_FILE" << 'EOF'
[Desktop Entry]
Name=OrcaSlicer
Exec=env GDK_SCALE=1 /opt/orca-slicer/bin/orca-slicer %F
Icon=OrcaSlicer
Type=Application
Categories=Utility;
MimeType=model/stl;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;application/x-amf;x-scheme-handler/orcaslicer;
EOF

# Verify the launcher was created
if [ -f "$LAUNCHER_FILE" ]; then
    log "Custom launcher created successfully"
    log "OrcaSlicer will launch with GDK_SCALE=1 to fix display issues"
else
    warn "Failed to create custom launcher at $LAUNCHER_FILE"
    exit 1
fi
