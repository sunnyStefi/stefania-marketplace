<div align="center">

# ⏱️ hour-registration

**A Claude Code plugin that runs your entire billing cycle on autopilot — calendar → timesheets → work slips → email administration.**

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-D97757?style=for-the-badge&logo=anthropic&logoColor=white)](https://claude.ai/code)
[![Schedule](https://img.shields.io/badge/automated-launchd-blue?style=for-the-badge&logo=apple&logoColor=white)](#scheduling)
[![Platform](https://img.shields.io/badge/macOS-only-lightgrey?style=for-the-badge&logo=apple&logoColor=white)](#)

</div>

---

## 🗓️ Weekly — every Friday

```sh
/hour-registration:weekly-tasks
```

Reads Work calendar → saves to `hour-registration/data/worked_hours.json` → submits hours to CLIENT and EMPLOYER.

> **Automated:** runs every Friday at **10:00** via macOS `launchd` (see [Scheduling](#-scheduling)).

---

## 📆 Monthly — first Monday of the month

```sh
/hour-registration:monthly-tasks
```

Downloads previous month's timesheets (CLIENT) and NS travel history → asks for confirmation → emails work slips + travel costs to EMPLOYER admin → deletes the download folder.

> Download paths use `MM-YY` format (e.g. April 2026 → `04-26`). Always targets the **previous** month (Europe/Amsterdam timezone).

> **Automated:** runs on the first Monday of each month at **10:00** via macOS `launchd` (see [Scheduling](#-scheduling)).

---

## ⏰ Scheduling

Both commands run automatically via macOS `launchd` jobs.

### Files

| File | Purpose |
|------|---------|
| `schedule/run-weekly-worksheet.sh` | Weekly wrapper script |
| `schedule/com.claude.weekly-worksheet.plist` | launchd job (every Friday 10:00) |
| `schedule/run-monthly-worksheet.sh` | Monthly wrapper script |
| `schedule/com.claude.monthly-worksheet.plist` | launchd job (every Monday 10:00; script skips non-first Mondays) |
| `schedule/install.sh` | One-shot setup — patches paths and registers both agents |
| `~/.claude/jobs/weekly-worksheet.log` | Weekly stdout log |
| `~/.claude/jobs/weekly-worksheet-error.log` | Weekly stderr log |
| `~/.claude/jobs/monthly-worksheet.log` | Monthly stdout log |
| `~/.claude/jobs/monthly-worksheet-error.log` | Monthly stderr log |

### First-time setup

Run `install.sh` once from the `schedule/` directory:

```sh
zsh schedule/install.sh
```

This script:
1. Replaces the `/path/to/hour-registration` and `YOUR_USERNAME` placeholders in all schedule files with the real paths.
2. Copies both plists to `~/Library/LaunchAgents/` and loads them.
3. Creates the `~/.claude/jobs/` log directory.

### Manage the jobs

```sh
launchctl list | grep com.claude                                              # verify loaded
launchctl start com.claude.weekly-worksheet                                   # trigger weekly-tasks immediately
launchctl start com.claude.monthly-worksheet                                  # trigger monthly-tasks immediately
launchctl unload ~/Library/LaunchAgents/com.claude.weekly-worksheet.plist    # pause weekly
launchctl unload ~/Library/LaunchAgents/com.claude.monthly-worksheet.plist   # pause monthly
```

> **Requirements:** Mac must be awake and logged in at the scheduled times. If the machine was asleep and misses the Friday 10:00 window, launchd will fire the job when it next wakes — the weekly-tasks command handles this gracefully.

---

## 📍 Location rules

All location-to-system mappings live in `rules/config.md`, alongside the rest of the personal configuration. Edit only that file when adding a new client site or changing a project code — it is the **single source of truth**.

---

## 🧰 Setup

### 1. Install the plugin

```sh
/plugin install /path/to/hour-registration
```

### 2. Configure credentials

Pick any keychain service names you like for CLIENT and EMPLOYER (the examples below use `worksheet-client` and `worksheet-employer`), then record those exact names in the **Credentials** section of `rules/config.md` so the commands can find them.

```sh
security add-generic-password -s "worksheet-client"    -a username -w "YOUR_USERNAME" -U
security add-generic-password -s "worksheet-client"    -a password -w "YOUR_PASSWORD" -U
security add-generic-password -s "worksheet-employer"  -a username -w "YOUR_EMAIL"    -U
security add-generic-password -s "worksheet-employer"  -a password -w "YOUR_PASSWORD" -U
security add-generic-password -s "worksheet-ns"        -a username -w "YOUR_EMAIL"    -U
security add-generic-password -s "worksheet-ns"        -a password -w "YOUR_PASSWORD" -U
```

> The first time a Keychain entry is read, macOS will prompt — choose **Always Allow**. To update, re-run with `-U`. To inspect: open **Keychain Access.app** and search `worksheet-`.

### 3. Configure context

```sh
cp rules/config.md.example rules/config.md
```

Fill in your name, email, company contacts, NS card ID, project codes, and location rules table.

### 4. Set up scheduling

```sh
zsh schedule/install.sh
```

### 5. Configure MCP servers

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

### 6. Verify

Type `/hour-registration` in Claude Code — you should see **2 commands**: `monthly-tasks` and `weekly-tasks`.

---

<div align="center">

**One Friday morning. Zero portals. Done before coffee.**

</div>
