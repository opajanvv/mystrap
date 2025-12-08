<objective>
Implement an idempotent DHCP/DNS configuration fix for Omarchy systems.
This addresses the issue where systemd-resolved is present but disabled on fresh installs,
causing DNS queries to bypass Pi-hole and use public resolvers.

Reference: https://opa.janvv.nl/blog/2025-10-13-omarchy-fix-dhcp
</objective>

<context>
Read @CLAUDE.md for project conventions.
Review @packages.txt to verify dhclient and systemd are present.
Review @scripts/helpers.sh for utility functions.

The fix requires:
1. Configure systemd-resolved to use stub resolver
2. Enable systemd-resolved service
3. Force DHCP lease renewal to apply DNS settings
</context>

<requirements>
1. Create post-install script for systemd-resolved package
2. Script must be idempotent - check current state before making changes
3. Verify configuration using `resolvectl status` output
4. Only make changes if needed (resolv.conf mode != foreign, DNS server not in homelab range 192.168.*.*, DNS Domain != local)
5. Use POSIX sh compatibility (no bash-specific features)
6. Handle cases where systemd-resolved is already configured correctly
</requirements>

<verification_logic>
The script should check `resolvectl status` global section for:
- resolv.conf mode: should be "foreign"
- Current DNS Server: should be in homelab range (192.168.*.*)
- DNS Domain: should be "local"

Only run configuration steps if any of these conditions are not met.
Parse DNS Server IP and check if it matches pattern 192.168.*.* using POSIX-compliant string matching.
</verification_logic>

<post_install_script_requirements>
Create install/systemd-resolved.sh:
- Start with: #!/bin/sh and set -eu
- Source helpers: . "$(dirname "$0")/../scripts/helpers.sh"
- Use logging: log(), warn(), die()
- Check if systemd-resolved is already configured correctly
- If not configured:
  1. Create symlink: ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
  2. Enable and start service: systemctl enable --now systemd-resolved
  3. Renew DHCP lease: dhclient -r && dhclient
- Verify configuration after changes using resolvectl status
- Make idempotent: skip steps already completed
</post_install_script_requirements>

<implementation_notes>
- systemd-resolved should already be in packages.txt (verify this)
- dhclient should already be in packages.txt (verify this)
- The script needs sudo/root privileges to run systemctl and modify /etc/resolv.conf
- Use `has_cmd resolvectl` to verify resolvectl is available
- Parse `resolvectl status` output carefully for the global section
- The dhclient renewal should use the system's default network interface
</implementation_notes>

<output>
Create files:
- `./install/systemd-resolved.sh` - Post-install script with idempotent DHCP/DNS fix
- Verify `systemd-resolved` is in `./packages.txt` (add if missing)
- Verify `dhclient` is in `./packages.txt` (add if missing)
</output>

<verification>
- Syntax check: shellcheck ./install/systemd-resolved.sh
- POSIX compliance: no bash-specific features used
- Test on laptop1 or laptop2:
  1. Run: sudo ./install/systemd-resolved.sh
  2. Check: resolvectl status | grep -A 10 "Global"
  3. Verify: resolv.conf mode is "foreign"
  4. Verify: Current DNS Server is in range 192.168.*.* (homelab range)
  5. Verify: DNS Domain is "local"
- Idempotency test: run script twice, second run should detect correct config and skip changes
- Integration test: ./install_all.sh --force
</verification>

<expected_resolvectl_output>
After successful configuration, `resolvectl status` should show:

Global
       Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
resolv.conf mode: foreign
     DNS Servers: 192.168.*.* (any IP in homelab range, e.g., 192.168.144.20)
      DNS Domain: local
</expected_resolvectl_output>
