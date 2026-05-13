#!/bin/zsh
# Runs the weekly worksheet orchestrator non-interactively.
# Triggered by launchd every Friday at 10:00.
# Logs go to ~/.claude/jobs/weekly-worksheet.log

cd "/Users/stefania/Spec Driven Development/hours-registration" && \
/Users/stefania/.local/bin/claude --print "/worksheet:weekly-tasks:0. weekly-orchestrator"
