<objective>
Enhance the logging system in scripts/helpers.sh with timestamps and automatic log cleanup.
Add datetime stamps (yyyy-mm-dd hh:mm format) to all log functions (log, warn, die).
Implement automatic cleanup mechanism to keep only the most recent 24 hours of log entries
in ~/.janstrap-auto-update.log.
</objective>

<context>
Read @CLAUDE.md for project conventions.
Review @scripts/helpers.sh for current logging functions.
Examine auto-update scripts that use ~/.janstrap-auto-update.log.

Current logging functions:
- log() - Outputs [INFO] messages
- warn() - Outputs [WARN] messages to stderr
- die() - Outputs [ERROR] messages to stderr and exits

These functions are used throughout the bootstrap scripts.
</context>

<requirements>
1. Modify log(), warn(), and die() functions to include timestamps
2. Timestamp format: yyyy-mm-dd hh:mm (e.g., "2025-12-08 21:30")
3. Create new cleanup_old_logs() helper function
4. Cleanup function should remove log entries older than 24 hours
5. Target log file: ~/.janstrap-auto-update.log
6. Use POSIX sh compatibility (no bash-specific features)
7. Ensure existing scripts using these functions continue to work unchanged
</requirements>

<timestamp_implementation>
Use POSIX-compliant date command for timestamps:
- Format: $(date '+%Y-%m-%d %H:%M')
- This works in standard sh without bash extensions

Modify logging functions to prepend timestamp:
- log(): echo "[$(date '+%Y-%m-%d %H:%M')] [INFO] $*"
- warn(): echo "[$(date '+%Y-%m-%d %H:%M')] [WARN] $*" >&2
- die(): echo "[$(date '+%Y-%m-%d %H:%M')] [ERROR] $*" >&2; exit 1

The timestamp should be the first element, before the severity level.
</timestamp_implementation>

<log_cleanup_implementation>
Create cleanup_old_logs() function:
- Takes log file path as parameter (default: ~/.janstrap-auto-update.log)
- Calculates cutoff time (24 hours ago)
- Removes log lines with timestamps older than 24 hours
- Preserves log lines without timestamps (for backward compatibility)
- Safe to run even if log file doesn't exist

POSIX-compliant approach:
1. Calculate cutoff timestamp (24 hours ago) using date command
2. Parse log file line by line
3. Extract timestamp from each line (format: [yyyy-mm-dd hh:mm])
4. Compare timestamp to cutoff
5. Keep lines newer than cutoff, discard older ones
6. Write filtered content back to temp file, then move to original

Handle edge cases:
- Log file doesn't exist (exit gracefully)
- Lines without timestamps (keep them)
- Empty log file (no action needed)
- Concurrent access (use atomic file operations)
</log_cleanup_implementation>

<output>
Modify files:
- `./scripts/helpers.sh` - Update log(), warn(), die() functions with timestamps
- `./scripts/helpers.sh` - Add new cleanup_old_logs() function
</output>

<verification>
- Syntax check: shellcheck ./scripts/helpers.sh
- POSIX compliance: no bash-specific features used
- Test timestamp format:
  1. Source helpers.sh
  2. Run: log "Test message"
  3. Verify output: [2025-12-08 21:30] [INFO] Test message
- Test log cleanup:
  1. Create test log file with timestamps spanning > 24 hours
  2. Run: cleanup_old_logs /path/to/test.log
  3. Verify: Only entries from last 24 hours remain
- Test with real auto-update log:
  1. Run: cleanup_old_logs ~/.janstrap-auto-update.log
  2. Verify: Old entries removed, recent entries preserved
- Backward compatibility: Existing scripts continue to work without changes
</verification>

<implementation_notes>
- The date command with '+%Y-%m-%d %H:%M' format is POSIX-compliant
- Timestamp parsing must handle the bracket format: [yyyy-mm-dd hh:mm]
- Use awk or sed for log parsing (POSIX-compliant tools)
- Atomic file operations: write to temp file, then mv to original
- The cleanup function should be callable from cron or auto-update scripts
- Consider adding cleanup_old_logs call to enable_auto_update.sh script
- Log cleanup should be idempotent and safe to run multiple times
</implementation_notes>

<usage_examples>
After implementation, the cleanup function can be used:

# Clean up auto-update log (default)
cleanup_old_logs

# Clean up specific log file
cleanup_old_logs /path/to/custom.log

# In auto-update script
log "Starting auto-update"
cleanup_old_logs  # Clean old entries before adding new ones
# ... rest of auto-update logic
</usage_examples>

<date_comparison_approach>
For POSIX-compliant date comparison:
1. Convert timestamps to Unix epoch seconds using date -d (if available)
2. Or use string comparison if timestamps are in ISO format (yyyy-mm-dd hh:mm)
3. Calculate cutoff: $(date -d '24 hours ago' '+%Y-%m-%d %H:%M')
4. Compare log line timestamp to cutoff using string comparison or epoch conversion

Handle systems without date -d support:
- Use date -v (BSD/macOS) as fallback
- Or use awk to parse and compare timestamps
</date_comparison_approach>
