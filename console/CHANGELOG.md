# Changelog

## 0.1.4

- Nothing in the console; the version follows the service.

## 0.1.3

- Sources, destinations and the folders of a destination (under its row and in its form) drag by a
  handle (⠿) at the start of the row; the order is saved as it drops, and goes back if the service
  refuses it. Backups has a *Manual* sort that drags the same way. With a search or a filter on,
  the handles are dimmed and say why.
- Saving the canvas keeps the order of the sources and destinations, on it or off it.

## 0.1.2

- Workspaces: **Export all** downloads every workspace as a JSON file, and each card exports its
  own; **Import** opens a dialog to drop or choose that file, shows what it adds (a taken name as
  `Prod (2)`) and adds it.
- The settings button of a workspace is a gear; the export arrow points down (the file comes to
  you) and the import arrow up.
- Deleting a workspace: the name to type stands out, and Enter deletes once it matches.
- Backups: a next run more than a day away reads `30 d 5 h` instead of `725 h 39 min` (and so do
  the durations of runs); the clock at the foot of the table ticks on its own.
- Spanish: *Orígenes* and *Destinos* everywhere; their own screens said *source* and
  *destination* (`Nuevo source`).
- The cron ⓘ of a config opens wider (480 px), so its lines don't wrap.
- A disabled config shows *Disabled* instead of its cron, on the canvas, in Backups and in the
  detail of its source; in its dialog, turning it off turns off the frequency and the cron.

## 0.1.1

- No changes in the console: the README drops its Railway section, now that the
  [Railway template](https://railway.com/deploy/dumpling) explains the deploy in its overview.

## 0.1.0

- The source and destination forms follow the design: the name goes in the first step, with the
  type; the connection test is in the second, next to the fields it checks (with TLS, for a
  source), and *Next* waits for a test that connects. A destination tests its bucket root there,
  and in the last step each new folder (*Check n folders*) before saving.
- The cron of a config has an ⓘ, as in the design: its five fields, some examples and the syntax.
- Backups: *Next backup in* counts down every second and shows only the seconds in its last minute
  (it stayed at `1 min 0 s`). Once the backup is due it says *Updating in 3…, 2…, 1…* and the list
  reloads with its run and the next one; meanwhile the due rows show *Loading*.
- The splash follows the design: the mark, the name, *Connecting to the backup service…* and a bar
  on the grid, the same from the first paint of the page until the console starts.
- The console starts in the language of the browser when it is Spanish, and in English otherwise
  (it always started in English); the one chosen with the flag still wins.
- Where a file went, the log and the error of a run, the connection values of a source or
  destination and the error of a failed check can be selected and copied.

## 0.1.0-rc.7

- No changes in the console: the version follows the service's.

## 0.1.0-rc.6

- A config created on the canvas starts with the schedule, compression and object key of the
  workspace, so its dialog shows them instead of empty fields.

## 0.1.0-rc.5

- No changes in the console: the version follows the service's.

## 0.1.0-rc.4

- No changes in the console: the version follows the service's.

## 0.1.0-rc.3

- No changes in the console: a new version now shows on reload (the service serves it with
  `Cache-Control: no-cache`).

## 0.1.0-rc.2

- The wordmark has a version for light backgrounds (`docs/design/brand/wordmark-light.svg`):
  the README shows one or the other with the theme of GitHub.

## 0.1.0-rc.1

The first release candidate, on the API of the service.

- Sign in, with the error of the service in the form; while it signs in only the form's side is
  blurred. Back to the page asked for after signing in; a session that expires keeps the screen
  under a dialog that signs in again.
- Workspaces: cards with counts, health and last run; create; settings with the defaults; delete
  by typing its name; switch from the rail or the URL.
- Every screen has its own path: bookmarks, reloads, back and forward.
- The rail splits its items with dividers and expands from a notch on its edge, each item with
  its name.
- Sources and destinations: list or cards with search and type filter, the logo of each type,
  create, edit, duplicate, test and delete; the folders of each bucket from its row. Created and
  edited in a dialog in steps as tall as the screen; each step starts with what the steps before
  chose. A source has a TLS selector (on by default, with a warning when turned off).
- The canvas, loaded from and saved to the service: Save (only with changes), Test run, and a
  dialog in steps per config (name, frequency or cron, enabled, object key with a preview and a
  list of its placeholders, compression, Run now). An empty cron goes back to the workspace's
  schedule. Its nodes show the logo of their type, and each config its last and next run in UTC
  and local time. A guide for an empty workspace. The right click opens only the menu of the
  canvas. Leaving it, or signing out, with edits asks first; Discard drops them.
- Warnings that don't block: a name too long to read on the canvas, gzip on top of a custom dump.
- Backups: healthy, failing and the next run; every backup with its last and next run, filters,
  sort and Run now.
- Run log: every run with filters by status, source type and destination type; a row opens on
  where the file went, the error and the log, which can be copied.
- Not found and Connection lost pages; each screen loads as a skeleton of itself.
- English and Spanish; times in UTC with the local time next to them.

## 0.0.1

Proof of concept of the pipeline canvas, with a demo pipeline (nothing is saved yet).

- Sources, configs and destinations as nodes: drag them, click to select a config.
- Drag from a source port to a folder or bucket to create a config, or onto a config to give it
  that source; from a config's out port to (re)connect it to a destination.
- Click a connection and remove it (its trash button or `Del`): sources, configs and destinations
  can be left unconnected. `Del` with no connection picked deletes the selected config.
- Only complete flows (database → config → destination) are kept: everything else (a config missing
  an end, a database or destination with no complete config, and their wires) is drawn in amber,
  and a warning says it is discarded when the pipeline is saved.
- The add toolbar, the warning and the view controls (with their popovers) sit on the left.
- Right click: on a connection or a node, remove / delete it; on empty space, add a database or a
  destination there. A click on empty space clears the selection.
- Pan only with Space + drag (or the middle button), scroll or arrow keys; zoom (Ctrl + scroll,
  `+` / `-`), center (`F`), reset (`0`), close the config (`Esc`).
- Shortcuts help (`?` or the keyboard button) and canvas settings open above the view controls,
  one at a time.
- Inspector of the selected config: frequency, object key and the path the next run writes.
