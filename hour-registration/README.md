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

Steps 4–5 run without pausing; step 6 asks for confirmation before sending and cleans up the download folder afterwards.

| Step | Command | What it does |
|------|---------|--------------|
| 4 | `download-hours-eneco` | Downloads previous month's timesheets from Eneco Fieldglass |
| 5 | `download-ns-reishistorie` | Downloads previous month's NS travel history |
| 6 | `send-email-administration` | Emails work slips + travel costs to Sourcelabs admin, then deletes the download folder |

> Download paths use `MM-YY` format (e.g. April 2026 → `04-26`). Orchestrators always target the **previous** month (Europe/Amsterdam timezone).

**Automated:** runs on the first Monday of each month at 08:00 via macOS `launchd` (see [Scheduling](#scheduling)).

---

## Scheduling

Both orchestrators run automatically via macOS `launchd` jobs.

### Files

| File | Purpose |
|------|---------|
| `schedule/run-weekly-worksheet.sh` | Weekly wrapper script |
| `schedule/com.claude.weekly-worksheet.plist` | launchd job (every Friday 10:00) |
| `schedule/run-monthly-worksheet.sh` | Monthly wrapper script |
| `schedule/com.claude.monthly-worksheet.plist` | launchd job (every Monday 08:00; script skips non-first Mondays) |
| `schedule/install.sh` | One-shot setup — patches paths and registers both agents |
| `~/.claude/jobs/weekly-worksheet.log` | Weekly stdout log |
| `~/.claude/jobs/weekly-worksheet-error.log` | Weekly stderr log |
| `~/.claude/jobs/monthly-worksheet.log` | Monthly stdout log |
| `~/.claude/jobs/monthly-worksheet-error.log` | Monthly stderr log |

### First-time setup

Run `install.sh` once from the `schedule/` directory:

```bash
zsh schedule/install.sh
```

This script:
1. Replaces the `/path/to/hour-registration` and `YOUR_USERNAME` placeholders in all schedule files with the real paths.
2. Copies both plists to `~/Library/LaunchAgents/` and loads them.
3. Creates the `~/.claude/jobs/` log directory.

### Manage the jobs

```bash
launchctl list | grep com.claude                                              # verify loaded
launchctl start com.claude.weekly-worksheet                                   # trigger weekly immediately
launchctl start com.claude.monthly-worksheet                                  # trigger monthly immediately
launchctl unload ~/Library/LaunchAgents/com.claude.weekly-worksheet.plist    # pause weekly
launchctl unload ~/Library/LaunchAgents/com.claude.monthly-worksheet.plist   # pause monthly
```

**Requirements:** Mac must be awake and logged in at the scheduled times. If the machine was asleep and misses the Friday 10:00 window, launchd will fire the job when it next wakes — the weekly orchestrator handles this gracefully.

---

## Location rules

All location-to-system mappings live in one file:

```
rules/locations.md
```

Edit only this file when adding a new client site — all three weekly steps read from it automatically. Project codes (e.g. `Eneco-Stefania`) must match the values in `rules/context.md`; update both files together if a project code changes.

---

## Setup

### 1. Install the plugin

```
/plugin install /path/to/hour-registration
```

### 2. Configure credentials

```bash
security add-generic-password -s "worksheet-fieldglass"  -a username -w "YOUR_USERNAME" -U
security add-generic-password -s "worksheet-fieldglass"  -a password -w "YOUR_PASSWORD" -U
security add-generic-password -s "worksheet-sourcelabs"  -a username -w "YOUR_EMAIL"    -U
security add-generic-password -s "worksheet-sourcelabs"  -a password -w "YOUR_PASSWORD" -U
security add-generic-password -s "worksheet-ns"          -a username -w "YOUR_EMAIL"    -U
security add-generic-password -s "worksheet-ns"          -a password -w "YOUR_PASSWORD" -U
```

The first time a Keychain entry is read, macOS will prompt — choose **Always Allow**. To update, re-run with `-U`. To inspect: open **Keychain Access.app** and search `worksheet-`.

### 3. Configure context

```bash
cp rules/context.md.example rules/context.md
```

Fill in your name, email, company contacts, NS card ID, and project codes.

### 4. Set up scheduling

```bash
zsh schedule/install.sh
```

### 5. Configure MCP servers

Edit `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "playwright":        { "command": "npx", "args": ["@playwright/mcp@latest"] },
    "google-calendar":   { "command": "npx", "args": ["@modelcontextprotocol/server-google-calendar"] },
    "microsoft-365":     { "command": "npx", "args": ["@modelcontextprotocol/server-microsoft-365"] }
  }
}
```

Restart Claude Desktop after saving.

### 6. Verify

Type `/hour-registration` in Claude Code — you should see all 6 commands listed under `monthly-tasks` and `weekly-tasks`.
