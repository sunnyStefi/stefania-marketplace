#!/bin/zsh
# Runs the monthly worksheet orchestrator on the first Monday of the month.
# Triggered by launchd every Monday at 10:00; guard exits silently on non-first Mondays.
# Logs go to ~/.claude/jobs/monthly-worksheet.log
# Update PROJECT_DIR to the path where hour-registration is installed.

PROJECT_DIR="/path/to/hour-registration"

# Only execute on the first Monday of the month (day 1–7)
day=$(date +%d)
(( day > 7 )) && exit 0

cd "$PROJECT_DIR" && \
~/.local/bin/claude --print "/hour-registration:monthly-tasks"
