---
name: weekly-tasks
description: "List this week's worked hours from Google Calendar and submit them to CLIENT and EMPLOYER."
model: sonnet
---

Run both weekly steps in sequence without pausing. CLIENT and EMPLOYER are defined in `rules/config.md` (Companies section).

## Week definition

"Current week" = the ISO 8601 week (Mon–Sun) that contains **today's date**, in the **Europe/Amsterdam** timezone. If today is Saturday or Sunday, use the week that just ended (the most recently completed Mon–Fri span). If the job fires on a Saturday or Sunday (e.g. machine was asleep on Friday), the current week is still the week that just ended — do not skip it.

## Step 1 — List hours from calendar

Use the Google Calendar MCP server to access the work calendar named in the **Calendar** section of `rules/config.md` and retrieve all workdays for the current week (Monday through Friday).

For each workday (Mon–Fri), determine the total hours and location using the **location rules**.

Save the result to `hour-registration/data/worked_hours.json`. The directory is created if it does not exist. The top-level object includes an ISO week identifier so subsequent steps can verify they are operating on the correct week. Dates are ISO `YYYY-MM-DD`.

```json
{
  "week": "YYYY-WNN",
  "days": [
    { "date": "YYYY-MM-DD", "hours": 8, "location": "Client" },
    { "date": "YYYY-MM-DD", "hours": 8, "location": "Client" },
    { "date": "YYYY-MM-DD", "hours": 0, "location": "National Holiday" },
    { "date": "YYYY-MM-DD", "hours": 8, "location": "Amsterdam" },
    { "date": "YYYY-MM-DD", "hours": 8, "location": "Rotterdam" }
  ]
}
```

After saving, display the contents in the console for verification.

On error, do not write a partial or empty JSON file.

## Step 2 — Submit hours

Use the Playwright MCP server. Keychain service names come from the Credentials section of `rules/context.md`.

### Pre-check (once)

Read `hour-registration/data/worked_hours.json`. Compute the current ISO week (e.g. `2026-W20`) in the **Europe/Amsterdam** timezone. If it differs from the `week` field in the file, **stop** — do not submit to either system.

### Submit (run for each system)

Run the steps below **twice** — once per system row:

| Variable | CLIENT | EMPLOYER |
|---|---|---|
| `{url}` | `https://www.eu.fieldglass.cloud.sap/time_sheet_list.do?cf=1` | `https://app-administration-app.azurewebsites.net/time-tracking` |
| `{keychain}` | CLIENT keychain service from `rules/context.md` | EMPLOYER keychain service from `rules/context.md` |
| `{already-submitted}` | status is not `Draft` / `Not submitted` | any non-zero hours already entered, or week is locked/submitted |
| `{columns}` | CLIENT hours column | EMPLOYER project, hours, and Thuiswerken Vergoeding columns |

1. Navigate to `{url}`. Log in with credentials from the macOS Keychain (service `{keychain}`, keys `username` and `password`).
2. **Check**: If `{already-submitted}`, skip this system and report it — do not re-submit.
3. **Enter hours**: For each day in `worked_hours.json.days`, enter hours per the **location rules** (`{columns}`). Click **Indienen** to submit.

## Error handling

On transient errors (network timeout, page crash), clear any partially entered fields before retrying.

**How to resume**: fix the reported issue, then re-run — duplicate-submission guards in step 2 prevent double-posting.
