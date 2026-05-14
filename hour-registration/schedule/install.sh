#!/bin/zsh
# One-shot setup for hour-registration schedule jobs.
# Run once from any directory after cloning — it resolves paths automatically.
# Re-running is safe; launchctl unload/load is idempotent.

set -e

SCHEDULE_DIR="${0:A:h}"
PROJECT_DIR="${SCHEDULE_DIR:h}"

echo "Project directory: $PROJECT_DIR"

# Substitute placeholders in schedule scripts and plists
for f in \
  "$SCHEDULE_DIR/run-weekly-worksheet.sh" \
  "$SCHEDULE_DIR/run-monthly-worksheet.sh" \
  "$SCHEDULE_DIR/com.claude.weekly-worksheet.plist" \
  "$SCHEDULE_DIR/com.claude.monthly-worksheet.plist"
do
  sed -i '' \
    -e "s|/path/to/hour-registration|$PROJECT_DIR|g" \
    -e "s|/Users/YOUR_USERNAME|$HOME|g" \
    "$f"
done

chmod +x "$SCHEDULE_DIR/run-weekly-worksheet.sh"
chmod +x "$SCHEDULE_DIR/run-monthly-worksheet.sh"

# Ensure log directory exists
mkdir -p "$HOME/.claude/jobs"

# Install and load launchd agents
for plist in \
  com.claude.weekly-worksheet.plist \
  com.claude.monthly-worksheet.plist
do
  dest="$HOME/Library/LaunchAgents/$plist"
  cp "$SCHEDULE_DIR/$plist" "$dest"
  launchctl unload "$dest" 2>/dev/null || true
  launchctl load "$dest"
  echo "Loaded $plist"
done

echo ""
echo "Done."
echo "  Weekly job  : every Friday at 10:00"
echo "  Monthly job : first Monday of each month at 10:00"
echo ""
echo "Verify with:"
echo "  launchctl list | grep com.claude"
