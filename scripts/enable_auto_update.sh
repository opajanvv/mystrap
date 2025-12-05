#!/bin/sh
# enable_auto_update.sh - Set up automatic updates via cron

set -eu

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source helpers
. "$SCRIPT_DIR/helpers.sh"

log "JanStrap Auto-Update Setup"
log "======================="
echo ""

# Check if cron is available
if ! has_cmd crontab; then
    die "crontab not found. Please install cron first."
fi

# Check if auto-update is already enabled
if crontab -l 2>/dev/null | grep -q "janstrap.*install_all.sh"; then
    warn "Auto-update appears to be already enabled in crontab."
    echo "Current JanStrap-related cron jobs:"
    crontab -l 2>/dev/null | grep "janstrap.*install_all.sh" || true
    echo ""
    echo "Remove the existing entry first with: ./scripts/disable_auto_update.sh"
    exit 1
fi

# Get schedule preference
echo "How often should JanStrap check for updates and apply them?"
echo ""
echo "  1) Every hour (recommended)"
echo "  2) Every 6 hours"
echo "  3) Every 12 hours"
echo "  4) Daily (at 2 AM)"
echo "  5) Custom cron schedule"
echo ""
printf "Enter choice [1-5]: "
read -r choice

case "$choice" in
    1) CRON_SCHEDULE="0 * * * *" ;;
    2) CRON_SCHEDULE="0 */6 * * *" ;;
    3) CRON_SCHEDULE="0 */12 * * *" ;;
    4) CRON_SCHEDULE="0 2 * * *" ;;
    5)
        echo ""
        echo "Enter custom cron schedule (e.g., '*/30 * * * *' for every 30 minutes):"
        printf "Schedule: "
        read -r CRON_SCHEDULE
        ;;
    *)
        die "Invalid choice"
        ;;
esac

# Set up log file location
LOG_FILE="$HOME/.janstrap-auto-update.log"

# Create the cron job entry
CRON_JOB="$CRON_SCHEDULE cd $REPO_ROOT && ./install_all.sh >> $LOG_FILE 2>&1"

# Add to crontab
(crontab -l 2>/dev/null || true; echo "# JanStrap automatic updates"; echo "$CRON_JOB") | crontab -

echo ""
log "Auto-update enabled successfully!"
echo ""
echo "Schedule: $CRON_SCHEDULE"
echo "Log file: $LOG_FILE"
echo ""
echo "JanStrap will automatically:"
echo "  - Check for git updates"
echo "  - Apply changes when updates are found"
echo "  - Log all activity to $LOG_FILE"
echo ""
echo "To disable: ./scripts/disable_auto_update.sh"
echo "To view logs: tail -f $LOG_FILE"
