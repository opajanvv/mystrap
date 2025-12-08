<objective>
Remove the 1password package from all mystrap-managed systems.
This package should be uninstalled during the bootstrap process.
</objective>

<context>
Read @CLAUDE.md for project conventions.
Review @uninstall.txt for current packages to be removed.
Review @packages.txt to check if 1password is currently being installed.
</context>

<requirements>
1. Add 1password to uninstall.txt (if not already present)
2. Remove 1password from packages.txt (if present)
3. Ensure idempotent behavior - safe to run multiple times
</requirements>

<implementation_steps>
1. Check if uninstall.txt exists, create if needed
2. Add "1password" to uninstall.txt using append_if_absent pattern
3. Check packages.txt for "1password" entry and remove if present
4. Verify changes are correct
</implementation_steps>

<output>
Modify files:
- `./uninstall.txt` - Add 1password to the list of packages to remove
- `./packages.txt` - Remove 1password if present in the installation list
</output>

<verification>
- Confirm 1password appears in uninstall.txt
- Confirm 1password does not appear in packages.txt
- Test: ./install_all.sh --force on a test machine
- Verify: yay -Q 1password should show package not installed after bootstrap
</verification>

<notes>
- The uninstall_packages.sh script uses `yay -Rns` which removes packages and their unused dependencies
- This is idempotent - running multiple times won't cause errors if package already removed
- If 1password was never in packages.txt, only uninstall.txt needs modification
</notes>
