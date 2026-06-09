# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A small Bash-only TODO / project-progress tracker. There is no build, test, or
lint step — the deliverables are shell scripts. The repository tree mirrors the
target filesystem layout: paths under `etc/`, `root/`, and `usr/` are copied to
`/etc/`, `/root/`, and `/usr/` respectively at install time (see README.md).

## Installation / running

- Copy each file to its corresponding absolute path (`etc/cron.daily/*` →
  `/etc/cron.daily/`, `usr/local/bin/va.txt.progressbar.sh` → `/usr/local/bin/`,
  etc.).
- Create `/etc/avanzamenti.conf` defining `BASE` (e.g. `BASE=/home`). Every
  script hardcodes `BASE=/var/www` as a fallback, then sources this conf to
  override it. **When editing any script, preserve this two-line pattern**
  (`BASE=/var/www` followed by `. /etc/avanzamenti.conf`) — it is the only
  configuration mechanism.
- Run the dashboard manually: `/root/avanzamenti.sh` (requires
  `va.txt.progressbar.sh` to be sourceable, i.e. on `PATH` / in `/usr/local/bin`).
- The three `cron.daily` scripts run unattended once per day.

## Data model (the contract every script relies on)

Each project lives in a directory directly under `$BASE`. A directory is treated
as a project only if it contains a `TODO.md`. Task state is encoded by markers
**at the start of a line**:

- `- [ ]` — to do
- `- [v]` — done
- `- [x]` — dropped/cancelled

Note the inconsistency to respect when changing parsing: `burndown` counts with
anchored regex (`^- \[ \]`), while `avanzamenti.sh` counts with `grep -Fwc '[ ]'`
(unanchored, word-bounded). Changing one without the other will desync the
displayed totals.

Other per-project / global files:
- `TODO.md` may contain a `SAL PIANIFICATA <date>` line — `avanzamenti.sh`
  collects these across projects into the "PROSSIME SAL" (next milestones) list,
  sorted, top 5.
- A file matching `*disallineamenti*` in a project dir flags it as out-of-sync.
- `$BASE/notes.md` — free text shown at the top of the dashboard.
- `$BASE/burndown.md` and per-project `burndown.md` — one line per day,
  maintained by the `burndown` cron (it deletes the current day's line via
  `sed -i "/^$TODAY/d"` before re-appending, so re-running same-day is
  idempotent).

## The pieces

- `root/avanzamenti.sh` — the read-only dashboard. Iterates `$BASE/*`, prints a
  table (project, progress bar, %, disallineamenti, done-vs-todo, total), the
  upcoming SAL list, and the tail of the global burndown chart. `NPRG` tracks how
  many lines were already printed so the burndown tail length adapts to fit.
- `usr/local/bin/va.txt.progressbar.sh` — sourced library. `progressbar current total
  size width` renders the inline bar used by the dashboard; `show_progress` and
  `bar` are alternate renderers. All math uses `bc`.
- `etc/cron.daily/burndown` — appends today's remaining-task count + ASCII bar to
  each project's and the global `burndown.md`.
- `etc/cron.daily/backups` — for projects shaped as `$BASE/<p>/htdocs/<sub>/`,
  tars each `<sub>` into `$BASE/<p>/backups/files/<sub>/` and prunes archives
  older than 3 days.
- `etc/cron.daily/upgrades` — housekeeping for `$BASE/<p>/htdocs/<sub>/`: prunes
  old `var/spool`, `var/log`, and `tmp` contents, and if
  `htdocs/update.branch.conf` exists runs each app's
  `_src/_sh/_gw.upgrade.sh <branch>`. This assumes a separate framework convention
  that is not part of this repo.

## Conventions

Comments, commit messages, and on-screen labels are in Italian — match that when
contributing.
