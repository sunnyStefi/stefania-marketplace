---
name: monthly-tasks
description: "Download the previous month's timesheets and travel costs, then email them to administration."
model: sonnet
---

Run both monthly wrap-up steps in sequence. CLIENT and EMPLOYER are defined in `rules/context.md` (Companies section). `{MM-YY}` is the zero-padded month and two-digit year of the **previous** month, interpreted in the **Europe/Amsterdam** timezone (e.g. `04-26` for April 2026).

## Step 1 — Download documents

Use the Playwright MCP server. Keychain service names come from the Credentials section of `rules/context.md`.

`{NS_CARD_ID}` is read from the **NS card** section of `rules/context.md`.

| Variable | CLIENT | NS Reishistorie |
|---|---|---|
| `{name}` | CLIENT | NS Reishistorie |
| `{url}` | `https://www.eu.fieldglass.cloud.sap/time_sheet_list.do?cf=1` | `https://www.ns.nl/mijnns#/reishistorie?card={NS_CARD_ID}&period=previous-month` |
| `{keychain}` | CLIENT keychain service from `rules/context.md` | NS keychain service from `rules/context.md` |
| `{no-data-condition}` | no timesheets found for the previous month | no journeys found for the previous month |
| `{download-action}` | Download all timesheets for the previous month | Select all journeys (exclude **Automatisch saldo opladen**), choose **Download overzicht x declaraties**, click **Download** |

For each system (in order):

1. Navigate to `{url}`. Log in with credentials from the macOS Keychain (service `{keychain}`, keys `username` and `password`).
2. **Pre-check**: if `{no-data-condition}`, stop and report — do not create an empty file.
3. `{download-action}`.
4. Move downloaded file(s) to `~/Downloads/{MM-YY}/`.

## Step 2 — Send email

Read the following from `rules/context.md`:
- **Your email** from the Identity section
- **Admin name and email** from the Contacts section

Use the M365 MCP server to send an email with the following details:

- **From:** {your email}
- **To:** {admin email} ({admin name} — EMPLOYER administration)
- **Subject:** Werkbriefjes en reiskosten {vorige-maand}
- **Body:** Hoi {admin name}, hierbij mijn werkbriefjes en reiskosten van de maand {vorige-maand}
- **Attachments:** all files from `~/Downloads/{MM-YY}/`

### Pre-send checks

Before composing the email:

1. Verify `~/Downloads/{MM-YY}/` exists and contains at least one file. If the directory is missing or empty, **stop and report** — do not send an empty email.
2. List the files that will be attached and show a preview of the email so the content can be verified.

### Confirmation

Ask for confirmation before sending. Show the recipient, subject, and attachment list in the prompt.

### After sending

Once the email is confirmed sent:

1. Delete all files in `~/Downloads/{MM-YY}/`.
2. Remove the now-empty `~/Downloads/{MM-YY}/` directory.
3. Report: "Email sent and Downloads/{MM-YY}/ cleaned up."

If deletion fails, report the error but do **not** treat it as an email failure — the email was already sent.

## Error handling

If any step fails:

1. **Report clearly**: which step failed, what the error was, and what was (or was not) saved to `~/Downloads/{MM-YY}/`.
2. **How to resume**: fix the reported issue and re-run only the failed step. Step 1 is safe to re-run (it overwrites any partially downloaded files). Step 2 checks that the download directory is non-empty before sending.

For download timeouts: if retries are exhausted, report which file(s) could not be downloaded and leave the directory with any successfully saved files.
