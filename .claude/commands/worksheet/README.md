---
name: README
description: "Overview of the worksheet command suite for automating the monthly billing cycle."
---

# Worksheet

Automates the complete billing cycle: reading worked hours from Google Calendar, submitting timesheets to Eneco and Sourcelabs, downloading work slips and NS travel history, and emailing everything to administration.

> Run in **Claude Desktop** — commands rely on local MCP servers and shared local files.

---

## Weekly — every Friday

```
/worksheet:weekly-tasks:0. weekly-orchestrator
```

| Step | Command | What it does |
|------|---------|--------------|
| 1 | `list-weekly-hours-calendar` | Reads Work calendar → `~/.claude/data/worked_hours.json` |
| 2 | `add-weekly-hours-eneco` | Submits hours to Eneco Fieldglass |
| 3 | `add-weekly-hours-sourcelabs` | Submits hours to Sourcelabs Administratie |

**Automated:** runs every Friday at 10:00 via macOS `launchd` (see [Scheduling](#scheduling)).

---

## Monthly — first Monday of the month

```
/worksheet:monthly-tasks:0. monthly-orchestrator
```

Steps 4–5 run without pausing; step 6 asks for confirmation before sending.

| Step | Command | What it does |
|------|---------|--------------|
| 4 | `download-hours-eneco` | Downloads previous month's timesheets from Eneco Fieldglass |
| 5 | `download-ns-reishistorie` | Downloads previous month's NS travel history |
| 6 | `send-email-administration` | Emails work slips + travel costs to Sourcelabs admin |

> Download paths use `MM-YY` format (e.g. April 2026 → `04-26`). Orchestrators always target the **previous** month.

---

## Scheduling

The weekly orchestrator runs automatically via a macOS `launchd` job.

### Files

| File | Purpose |
|------|---------|
| `~/.claude/schedule/run-weekly-worksheet.sh` | Wrapper script |
| `~/.claude/schedule/com.claude.weekly-worksheet.plist` | launchd job (Friday 10:00) |
| `~/.claude/jobs/weekly-worksheet.log` | stdout log |
| `~/.claude/jobs/weekly-worksheet-error.log` | stderr log |

### First-time setup

```bash
chmod +x ~/.claude/schedule/run-weekly-worksheet.sh
cp ~/.claude/schedule/com.claude.weekly-worksheet.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.claude.weekly-worksheet.plist
```

### Manage the job

```bash
launchctl list | grep weekly-worksheet          # verify loaded
launchctl start com.claude.weekly-worksheet     # trigger immediately
launchctl unload ~/Library/LaunchAgents/com.claude.weekly-worksheet.plist   # pause
launchctl load   ~/Library/LaunchAgents/com.claude.weekly-worksheet.plist   # resume
```

**Requirements:** Mac must be awake and logged in at 10:00. Keep Claude Desktop running (or set it to launch at login: **System Settings → General → Login Items**).

---

## Location rules

All location-to-system mappings live in one file:

```
~/.claude/rules/worksheet-locations.md
```

Edit only this file when adding a new client site — all three weekly steps read from it automatically.

---

## Setup

### 1. Install Claude Desktop

Download from [claude.ai/download](https://claude.ai/download).

### 2. Place the commands

```
~/.claude/
  commands/worksheet/
    README.md
    weekly-tasks/   0. weekly-orchestrator.md  1–3. …
    monthly-tasks/  0. monthly-orchestrator.md  4–6. …
  schedule/
    run-weekly-worksheet.sh
    com.claude.weekly-worksheet.plist
```

### 3. Add credentials to Keychain

```bash
security add-generic-password -s "worksheet-fieldglass"  -a username -w "YOUR_USERNAME" -U
security add-generic-password -s "worksheet-fieldglass"  -a password -w "YOUR_PASSWORD" -U
security add-generic-password -s "worksheet-sourcelabs"  -a username -w "YOUR_EMAIL"    -U
security add-generic-password -s "worksheet-sourcelabs"  -a password -w "YOUR_PASSWORD" -U
security add-generic-password -s "worksheet-ns"          -a username -w "YOUR_EMAIL"    -U
security add-generic-password -s "worksheet-ns"          -a password -w "YOUR_PASSWORD" -U
```

The first time a Keychain entry is read, macOS will prompt — choose **Always Allow**. To update, re-run with `-U`. To inspect: open **Keychain Access.app** and search `worksheet-`.

### 4. Configure MCP servers

Edit `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "playwright":       { "command": "npx", "args": ["@playwright/mcp@latest"] },
    "google-calendar":  { "command": "npx", "args": ["@modelcontextprotocol/server-google-calendar"] },
    "microsoft-365":    { "command": "npx", "args": ["@modelcontextprotocol/server-microsoft365"] }
  }
}
```

Restart Claude Desktop after saving.

### 5. Verify

Type `/worksheet` in Claude Desktop — you should see all 6 commands listed.
