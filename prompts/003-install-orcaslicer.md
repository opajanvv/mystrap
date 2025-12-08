<objective>
Install OrcaSlicer (3D printer slicing software) on all Omarchy workstations.
Use the prebuilt AUR package (orca-slicer-bin) and create a custom desktop launcher
to fix display scaling issues caused by Omarchy's default GDK_SCALE=2.

Reference: https://opa.janvv.nl/blog/2025-11-16-omarchy-orcaslicer
</objective>

<context>
Read @CLAUDE.md for project conventions.
Review @packages.txt for current packages.
Review @scripts/helpers.sh for utility functions.

OrcaSlicer requires:
1. Installation of orca-slicer-bin package (AUR)
2. Custom desktop launcher with GDK_SCALE=1 to prevent display issues
</context>

<requirements>
1. Add orca-slicer-bin to packages.txt
2. Create post-install script at install/orca-slicer-bin.sh
3. Post-install script must create custom desktop launcher
4. Use POSIX sh compatibility (no bash-specific features)
5. Make idempotent - check if launcher already exists before creating
</requirements>

<post_install_script_requirements>
Create install/orca-slicer-bin.sh:
- Start with: #!/bin/sh and set -eu
- Source helpers: . "$(dirname "$0")/../scripts/helpers.sh"
- Use logging: log(), warn(), die()
- Check if custom desktop launcher already exists
- Create ~/.local/share/applications/ directory if it doesn't exist
- Create custom Orcaslicer.desktop file with GDK_SCALE=1 override
- Make idempotent: skip if launcher already configured correctly
</post_install_script_requirements>

<desktop_launcher_content>
The custom desktop launcher at ~/.local/share/applications/Orcaslicer.desktop should contain:

[Desktop Entry]
Name=OrcaSlicer
Exec=env GDK_SCALE=1 /opt/orca-slicer/bin/orca-slicer %F
Icon=OrcaSlicer
Type=Application
Categories=Utility;
MimeType=model/stl;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;application/x-amf;x-scheme-handler/orcaslicer;

The key fix is: Exec=env GDK_SCALE=1 /opt/orca-slicer/bin/orca-slicer %F
This overrides Omarchy's default GDK_SCALE=2 which causes display issues.
</desktop_launcher_content>

<implementation_notes>
- Use orca-slicer-bin (prebuilt) rather than orca-slicer (compile from source)
- The desktop launcher must be placed in user's home directory, not system-wide
- $HOME/.local/share/applications/ may need to be created
- The script should not require sudo (creates files in user's home only)
- Verify the launcher path /opt/orca-slicer/bin/orca-slicer exists after package install
</implementation_notes>

<output>
Modify/create files:
- `./packages.txt` - Add orca-slicer-bin package
- `./install/orca-slicer-bin.sh` - Post-install script to create custom desktop launcher
</output>

<verification>
- Syntax check: shellcheck ./install/orca-slicer-bin.sh
- POSIX compliance: no bash-specific features used
- Test on laptop1 or laptop2:
  1. Run: ./install_all.sh --force
  2. Verify package installed: yay -Q orca-slicer-bin
  3. Verify launcher exists: ls -la ~/.local/share/applications/Orcaslicer.desktop
  4. Verify launcher content: grep "GDK_SCALE=1" ~/.local/share/applications/Orcaslicer.desktop
  5. Test launch: Launch OrcaSlicer from application menu, verify UI displays correctly
- Idempotency test: run script twice, second run should detect existing launcher and skip creation
</verification>

<why_gdk_scale_fix>
Omarchy sets GDK_SCALE=2 by default for HiDPI displays. OrcaSlicer doesn't handle this well,
causing window rendering problems and interface elements to disappear off-screen.
The custom launcher overrides GDK_SCALE to 1 specifically for OrcaSlicer while preserving
system-wide scaling for other applications.
</why_gdk_scale_fix>
