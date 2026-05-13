---
paths:
  - "commands/worksheet/**/*.md"
---

# Worksheet location rules

Canonical mapping from a workday's `location` to how it should be entered in each system. All three weekly steps (`1. list-weekly-hours-calendar`, `2. add-weekly-hours-eneco`, `3. add-weekly-hours-sourcelabs`) must agree with this table — when adding a new location, update this file only.

## How each step uses the table

- **Step 1 — calendar** picks a `location` for each weekday based on the **Calendar match** column. If no event matches, fall back to `Eneco`.
- **Step 2 — Eneco Fieldglass** enters the **Eneco hours** value for that day.
- **Step 3 — Sourcelabs** enters the **Sourcelabs project**, **Sourcelabs hours**, and toggles **Thuiswerken Vergoeding** as listed.

## Location table

| Location          | Calendar match               | Eneco hours | Sourcelabs project          | Sourcelabs hours | Thuiswerken Vergoeding |
|-------------------|------------------------------|-------------|-----------------------------|------------------|------------------------|
| `Eneco`           | _no event scheduled_         | 8           | `Eneco-Stefania`            | 8                | checked                |
| `Amsterdam`       | event title contains `Amsterdam` | 8       | `Eneco-Stefania`            | 8                | unchecked              |
| `Rotterdam`       | event title contains `Rotterdam` | 8       | `Eneco-Stefania`            | 8                | unchecked              |
| `Utrecht`         | `Utrecht-Meetup`             | 0           | `Meetup`                    | 8                | n/a                    |
| `Leave`           | `Sick day`                   | 0           | `Verlof / Leave`            | 8                | n/a                    |
| `Vacation`        | `Vacation day`               | 0           | `Vakantie / Vacation`       | 8                | n/a                    |
| `National Holiday`| National Dutch Holiday       | 0           | `Feestdag / National Holiday` | 8              | n/a                    |

## Notes

- For Sourcelabs, `Eneco-Stefania` is entered on the default row; the other projects are added with the **+** button next to `Uren`.
- `Thuiswerken Vergoeding` only applies when the project is `Eneco-Stefania`; the column is `n/a` for the others.
- A `location` value not present in this table is an error — Step 1 must produce one of the keys above, and Steps 2 and 3 must refuse to proceed on unknown values.
