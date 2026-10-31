# Changelog

## Unreleased

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
