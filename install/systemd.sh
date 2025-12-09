#!/bin/sh
# Post-install script for systemd-resolved
# Configures systemd-resolved for DHCP/DNS with homelab DNS servers
# Reference: https://opa.janvv.nl/blog/2025-10-13-omarchy-fix-dhcp

set -eu

# Source helpers for logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../scripts/helpers.sh" 2>/dev/null || . "$(dirname "$SCRIPT_DIR")/scripts/helpers.sh"

# Check if we can use sudo without password
if ! sudo -n true 2>/dev/null; then
    warn "Cannot configure systemd-resolved without sudo access (run manually or configure passwordless sudo)"
    exit 0
fi

# Function to check if DNS server is in homelab range (192.168.*.*)
is_homelab_dns() {
    dns_server="$1"
    # Check if IP starts with 192.168.
    case "$dns_server" in
        192.168.*.*)
            return 0
            ;;
        192.168.*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Check current configuration
log "Checking current DNS configuration..."
resolv_status=$(resolvectl status 2>/dev/null || echo "")

if [ -z "$resolv_status" ]; then
    warn "Could not get resolvectl status"
    exit 1
fi

# Parse global section for current state
resolv_mode=$(echo "$resolv_status" | grep -A 10 "^Global" | grep "resolv.conf mode:" | sed 's/.*resolv.conf mode: //' | tr -d ' ')
dns_server=$(echo "$resolv_status" | grep -A 10 "^Global" | grep "DNS Servers:" | sed 's/.*DNS Servers: //' | awk '{print $1}' | tr -d ' ')
dns_domain=$(echo "$resolv_status" | grep -A 10 "^Global" | grep "DNS Domain:" | sed 's/.*DNS Domain: //' | tr -d ' ')

log "Current state: mode=$resolv_mode, DNS=$dns_server, domain=$dns_domain"

# Determine if configuration is needed
needs_config=0

if [ "$resolv_mode" != "foreign" ]; then
    log "resolv.conf mode is not 'foreign' (current: $resolv_mode)"
    needs_config=1
fi

if [ -n "$dns_server" ]; then
    if ! is_homelab_dns "$dns_server"; then
        log "DNS server is not in homelab range 192.168.*.* (current: $dns_server)"
        needs_config=1
    fi
else
    log "No DNS server configured"
    needs_config=1
fi

if [ "$dns_domain" != "local" ]; then
    log "DNS domain is not 'local' (current: $dns_domain)"
    needs_config=1
fi

# Exit if already configured correctly
if [ "$needs_config" -eq 0 ]; then
    log "systemd-resolved is already configured correctly, no changes needed"
    exit 0
fi

# Apply configuration
log "Applying systemd-resolved configuration..."

# Step 1: Create symlink for stub resolver
if [ ! -L /etc/resolv.conf ] || [ "$(readlink /etc/resolv.conf)" != "/run/systemd/resolve/stub-resolv.conf" ]; then
    log "Creating symlink: /etc/resolv.conf -> /run/systemd/resolve/stub-resolv.conf"
    sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
else
    log "Symlink already configured correctly"
fi

# Step 2: Enable and start systemd-resolved
if ! systemctl is-enabled systemd-resolved.service >/dev/null 2>&1; then
    log "Enabling systemd-resolved.service"
    sudo systemctl enable systemd-resolved.service
else
    log "systemd-resolved.service already enabled"
fi

if ! systemctl is-active systemd-resolved.service >/dev/null 2>&1; then
    log "Starting systemd-resolved.service"
    sudo systemctl start systemd-resolved.service
else
    log "systemd-resolved.service already running"
fi

# Step 3: Renew DHCP lease
log "Renewing DHCP lease to apply DNS settings..."
sudo dhclient -r >/dev/null 2>&1 || true
sleep 1
sudo dhclient >/dev/null 2>&1 || true
sleep 2

# Verify configuration
log "Verifying configuration..."
new_resolv_status=$(resolvectl status 2>/dev/null || echo "")
new_resolv_mode=$(echo "$new_resolv_status" | grep -A 10 "^Global" | grep "resolv.conf mode:" | sed 's/.*resolv.conf mode: //' | tr -d ' ')
new_dns_server=$(echo "$new_resolv_status" | grep -A 10 "^Global" | grep "DNS Servers:" | sed 's/.*DNS Servers: //' | awk '{print $1}' | tr -d ' ')
new_dns_domain=$(echo "$new_resolv_status" | grep -A 10 "^Global" | grep "DNS Domain:" | sed 's/.*DNS Domain: //' | tr -d ' ')

log "New state: mode=$new_resolv_mode, DNS=$new_dns_server, domain=$new_dns_domain"

if [ "$new_resolv_mode" = "foreign" ] && is_homelab_dns "$new_dns_server" && [ "$new_dns_domain" = "local" ]; then
    log "Configuration applied successfully!"
else
    warn "Configuration may not be complete. Check 'resolvectl status' manually."
fi
