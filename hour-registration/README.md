# hour-registration

Automates the complete billing cycle for consultants: reading worked hours from Google Calendar, submitting timesheets to Eneco and Sourcelabs, downloading work slips and NS travel history, and emailing everything to administration.

## Installation

Install from a marketplace:

```
/plugin install hour-registration@<marketplace>
```

Or install from a local path:

```
/plugin install /path/to/hour-registration
```

---

## Weekly — every Friday

```
/hour-registration:weekly-tasks:0. weekly-orchestrator
```

| Step | Command | What it does |
|------|---------|--------------|
| 1 | `list-weekly-hours-calendar` | Reads Work calendar → `hour-registration/data/worked_hours.json` |
| 2 | `add-weekly-hours-eneco` | Submits hours to Eneco Fieldglass |
| 3 | `add-weekly-hours-sourcelabs` | Submits hours to Sourcelabs Administratie |

**Automated:** runs every Friday at 10:00 via macOS `launchd` (see [Scheduling](#scheduling)).

---

## Monthly — first Monday of the month

```
/hour-registration:monthly-tasks:0. monthly-orchestrator
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
| `schedule/run-weekly-worksheet.sh` | Wrapper script |
| `schedule/com.claude.weekly-worksheet.plist` | launchd job (Friday 10:00) |
| `~/.claude/jobs/weekly-worksheet.log` | stdout log |
| `~/.claude/jobs/weekly-worksheet-error.log` | stderr log |

### First-time setup

```bash
chmod +x schedule/run-weekly-worksheet.sh
cp schedule/com.claude.weekly-worksheet.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.claude.weekly-worksheet.plist
```

### Manage the job

```bash
launchctl list | grep weekly-worksheet          # verify loaded
launchctl start com.claude.weekly-worksheet     # trigger immediately
launchctl unload ~/Library/LaunchAgents/com.claude.weekly-worksheet.plist   # pause
launchctl load   ~/Library/LaunchAgents/com.claude.weekly-worksheet.plist   # resume
```

**Requirements:** Mac must be awake and logged in at 10:00.

---

## Location rules

All location-to-system mappings live in one file:

```
rules/worksheet-locations.md
```

Edit only this file when adding a new client site — all three weekly steps read from it automatically.

---

## Setup

### 1. Install the plugin

```
/plugin install /path/to/hour-registration
```

### 2. Copy schedule files

```bash
cp schedule/run-weekly-worksheet.sh ~/.claude/schedule/
cp schedule/com.claude.weekly-worksheet.plist ~/.claude/schedule/
```

Update the paths inside both files to match your system.

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
    "playwright":      { "command": "npx", "args": ["@playwright/mcp@latest"] },
    "google-calendar": { "command": "npx", "args": ["@modelcontextprotocol/server-google-calendar"] }
  }
}
```

Restart Claude Desktop after saving.

### 5. Verify

Type `/hour-registration` in Claude Code — you should see all 6 commands listed under `monthly-tasks` and `weekly-tasks`.
