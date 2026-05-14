<div align="center">

# ⏱️ hour-registration

**A Claude Code plugin that runs your entire billing cycle on autopilot — calendar → timesheets → work slips → email administration.**

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-D97757?style=for-the-badge&logo=anthropic&logoColor=white)](https://claude.ai/code)
[![Schedule](https://img.shields.io/badge/automated-launchd-blue?style=for-the-badge&logo=apple&logoColor=white)](#scheduling)
[![Platform](https://img.shields.io/badge/macOS-only-lightgrey?style=for-the-badge&logo=apple&logoColor=white)](#)

</div>

---

## 📍 Personal information and location rules

All personal configuration lives in `rules/config.md` (gitignored). It is the single source of truth — edit only that file when changing personal details, project codes, or client sites. Copy `rules/config.md.example` to get started.

The file contains the following sections:

**Identity** — Your name and work email, used to sign the monthly administration email.

**Companies** — The display names for the two systems this plugin automates. `CLIENT` is your client's timesheet portal (where you log billable hours); `EMPLOYER` is your employer's internal time-tracking tool (where you register the same hours plus expense allowances).

**Contacts** — The person at your employer who receives the monthly email with work slips and travel costs.

**Project codes** — The codes used when entering hours in CLIENT and EMPLOYER. The default code covers all regular working days; add a row for each special project type your employer requires.

**Calendar** — The name of the Google Calendar where your work events are logged. The weekly command reads this to determine hours and location for each day.

**NS card** — Your NS public transport card ID, used to fetch your monthly travel history from ns.nl for the administration email.

**Credentials** — The macOS Keychain service names where login credentials are stored (each with a `username` and `password` key). See step 2 of setup below.

**Location rules** — Each workday gets a **location** label that determines what to enter in CLIENT and EMPLOYER for that day. The weekly command reads your calendar events to pick the right location, then uses the location table to translate it into hours and project codes.

The location table has five columns:

- **Location** — the internal label used in `worked_hours.json` and referenced by the submit step.
- **Calendar match** — the keyword the weekly command looks for in that day's events. Days with no matching event fall back to the first row (the default).
- **CLIENT hours** — hours to enter in the client portal. Non-billable days (leave, vacation, holidays, meetups) are 0 because those days are not submitted to the client.
- **EMPLOYER project** — the project code to select in the employer tool.
- **EMPLOYER hours** — hours to enter in the employer tool. Always 8 — the employer registers a full day regardless of billability.
- **Home work allowance** — whether to tick the allowance checkbox. Applies only to the default row; `n/a` for all others.

To add a new location (e.g. a new client site or office), add a row to the table and a matching calendar event keyword in the **Calendar match** column. The commands will refuse to proceed if they encounter a location not listed in the table.

---

## 🗓️ Weekly tasks

```sh
/hour-registration:weekly-tasks
```

Reads Work calendar → saves to `hour-registration/data/worked_hours.json` → submits hours to CLIENT and EMPLOYER.

> **Automated:** runs every Friday at **10:00** via macOS `launchd` (see [Scheduling](#-scheduling)).

---

## 📆 Monthly tasks

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

### 3. Configure

```sh
cp rules/config.md.example rules/config.md
```

Fill in your name, email, company contacts, NS card ID, project codes, and location rules table.

### 4. Set up scheduling

```sh
zsh schedule/install.sh
```

### 5. Verify

Type `/hour-registration` in Claude Code — you should see **2 commands**: `monthly-tasks` and `weekly-tasks`.

---

<div align="center">

**One Friday morning. Zero portals. Done before coffee.**

</div>
