<div align="center">

# ⏱️ Hour Registration

<img src="data/tiger-clock.jpg" alt="Tiger Clock" width="300"/>

**A Claude Code plugin that runs your entire billing cycle on autopilot — calendar → timesheets → work slips → email administration.**

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-D97757?style=for-the-badge&logo=anthropic&logoColor=white)](https://claude.ai/code)
[![Google Calendar](https://img.shields.io/badge/MCP-Google%20Calendar-4285F4?style=for-the-badge&logo=googlecalendar&logoColor=white)](#-weekly-tasks)
[![Playwright](https://img.shields.io/badge/MCP-Playwright-2EAD33?style=for-the-badge&logo=playwright&logoColor=white)](#)
[![Microsoft 365](https://img.shields.io/badge/MCP-Microsoft%20365-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)](#)
[![Schedule](https://img.shields.io/badge/automated-launchd-blue?style=for-the-badge&logo=apple&logoColor=white)](#scheduling)

</div>



- 🗓️ [Weekly tasks](#️-weekly-tasks)
- 📆 [Monthly tasks](#-monthly-tasks)
- ⚙️ [Setup](#-setup)
- ⏰ [Scheduling](#️-scheduling)

---

## 🗓️ Weekly tasks
Reads from your calendar → submits hours to CLIENT and EMPLOYER.
```sh
/hour-registration:weekly-tasks
```

> 🤖 **Automated:** runs every Friday at **10:00** via macOS `launchd` (see [Scheduling](#-scheduling)).


## 📆 Monthly tasks
Downloads CLIENT previous month's timesheets and NS travel history → emails work slips + travel costs to ADMINISTRATION

```sh
/hour-registration:monthly-tasks
```

> 🤖 **Automated:** runs on the first Monday of each month at **10:00** via macOS `launchd` (see [Scheduling](#-scheduling)).


## ⚙️ Setup

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

### 3. Configure

```sh
cp rules/config.md.example rules/config.md
```

Fill in your name, email, company contacts, NS card ID, project codes, and location rules table.

`rules/config.md` is the single source of truth for your personal information — edit only that file when changing personal details, project codes, or client sites.

### 4. Set up scheduling

```sh
zsh schedule/install.sh
```

### 5. Verify

Type `/hour-registration` in Claude Code — you should see **2 commands**: `monthly-tasks` and `weekly-tasks`.


## ⏰ Scheduling

Both commands run automatically via macOS `launchd` jobs.

### Files

| File | Purpose |
|------|---------|
| `schedule/install.sh` | One-shot setup — patches paths and registers both agents |
| `schedule/run-weekly-worksheet.sh` | Weekly wrapper script |
| `schedule/run-monthly-worksheet.sh` | Monthly wrapper script |
| `schedule/com.claude.weekly-worksheet.plist` | launchd job (every Friday 10:00) |
| `schedule/com.claude.monthly-worksheet.plist` | launchd job — fires every Monday at 10:00, runs only on the first Monday of the month |
| `~/.claude/jobs/weekly-worksheet.log` | Weekly log (stdout + stderr) |
| `~/.claude/jobs/monthly-worksheet.log` | Monthly log (stdout + stderr) |

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
