#!/bin/zsh
# Runs the weekly worksheet orchestrator non-interactively.
# Triggered by launchd every Friday at 10:00.
# Logs go to ~/.claude/jobs/weekly-worksheet.log
# Update PROJECT_DIR to the path where hour-registration is installed.

PROJECT_DIR="$HOME/path/to/hour-registration"

cd "$PROJECT_DIR" && \
~/.local/bin/claude --print "/hour-registration:weekly-tasks:weekly-tasks"
