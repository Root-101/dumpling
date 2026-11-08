# Changelog

What changes in each version of Dumpling, from 0.1.0. The detail of each package is in the
changelogs of [`service/`](service/CHANGELOG.md) and [`console/`](console/CHANGELOG.md), which also
have the release candidates before 0.1.0 one by one.

## 0.1.6

- 🔴 **The database changes** (a table `api_key`, and the label and key of each run): export your
  workspaces before upgrading and import them after (see [Upgrading](README.md#upgrading)).
- **API keys.** Each workspace has keys for other systems: a deploy pipeline that backs up its
  database before a migration, a script, a dashboard. A key has the permissions it was given (with
  templates: *Run backups*, *Read only*, *Full access*) and optionally only some configs (then it
  can't create configs nor use the canvas); it is sent as a Bearer token or with Basic auth, shown
  once, and doesn't expire. The new **API keys** screen lists, searches, filters, sorts, creates,
  edits and deletes them. Guide, with a pipeline that backs up before each deploy:
  [`docs/integrations.md`](docs/integrations.md).
- **A run asked for while its config runs waits its turn** (*Queued*) instead of a 409, and starts
  when that one ends.
- **A label on each run** (`{"label": "v1.4.2"}` on Run now), and who started it: the run log shows
  *API · the key* with the label, filters by who started it and finds a run by its label.
- **Follow a run as it goes:** `GET …/runs/{id}/events` streams it (Server-Sent Events) until it
  ends.
- A session open across an upgrade keeps reaching the routes the new version adds.
- Console: the confirmations before deleting or discarding look as in the design.

## 0.1.5

- Console: a dragged row drops into place without a flicker of the old order.

## 0.1.4

- **A health check**: `GET /api/health` answers `{"status": "up"}` without a token, or a `503`
  when the database doesn't answer, for load balancers and container checks.

## 0.1.3

- 🔴 **The database changes** (a `position` column in four tables): export your workspaces
  before upgrading and import them after (see [Upgrading](README.md#upgrading)).
- **Order by hand.** Sources, destinations, the folders of a destination and backups drag by a
  handle (⠿) into the order you want, and the service keeps it: the lists, the canvas and an
  export follow it. In Backups it is the *Manual* sort. With a search or a filter on, the handles
  are dimmed.
- API: `PUT /api/workspaces/{slug}/sources/order`, `…/destinations/order` and `…/configs/order`,
  with every id of the workspace in the new order. The folders of a destination come back in the
  order they were sent, no longer alphabetical.

## 0.1.2

- **Export and import of workspaces.** Workspaces exports every workspace to a JSON file, and each
  card exports its own: the canvas (sources, destinations, configs and where they sit), the
  credentials encrypted as they are stored and the run log of the last month. *Import* opens a
  dialog where the file is dropped or chosen; it shows what it adds and adds it, a name already
  taken as `Prod (2)`. The credentials only decrypt with the same `SECRETS_ENCRYPTION_KEY` as the
  Dumpling that exported them. It is how the data crosses a version that changes the schema of
  the database (see [Upgrading](README.md#upgrading)).
- **The image is published** on each release, for amd64 and arm64:
  `ghcr.io/root-101/dumpling:<version>` (`latest`, the last one without `-rc`). The
  `docker-compose.yml` runs it instead of building the repo, so it and `.env.example` are all
  that is needed; `PG_VERSION` is only a build arg now (the published image carries 18).
- API: `GET /api/export` (`?workspace=<slug>` for one) and `POST /api/import`, with the
  permissions `workspace.export` and `workspace.import`.
- Console: the settings of a workspace behind a gear; in the delete confirmation the name to type
  stands out, and Enter deletes once it matches. In Backups, a next run days away reads
  `30 d 5 h`, and the clock at the foot of the table ticks on its own. In Spanish, the screens of
  sources and destinations say *origen* and *destino*. A disabled config shows *Disabled*
  instead of its cron, and its dialog turns the cron off with it.

## 0.1.1

- No changes in the service or the console: the README drops its Railway section, now that the
  [Railway template](https://railway.com/deploy/dumpling) explains the deploy in its overview.

## 0.1.0

The first version, built over the release candidates `0.1.0-rc.1` (2026-10-30) to `rc.8`. What it
has:

- **Foundations:** the service (Winter 1.0.0, drift + SQLite in WAL, slang, Problem Details) and
  the console (Flutter Web, flutter_bloc, go_router), in English and Spanish (the browser's
  language at first). Credentials encrypted with AES-GCM and never returned. `SourceDriver` and
  `DestinationDriver` contracts with a registry of types, the planned ones shown as disabled. CI
  with analyze and tests of both packages.
- **Release:** one image where the service serves the console, with the `pg_dump` of
  `PG_VERSION`; `docker-compose.yml` and `.env.example`; it deploys on Railway (a Volume on
  `/data`). A new console shows on reload (`Cache-Control: no-cache`).
- **Auth:** one admin from the environment, a JWT of 12 h, failed logins limited per IP; an
  expired session signs in again over the screen.
- **Workspaces:** create, edit, delete by typing the name (which cancels its schedules; the files
  in the buckets stay); defaults for new configs; health on each card.
- **Sources and destinations:** PostgreSQL (fields or URL, custom or plain dumps, TLS by default)
  and S3-compatible (our own SigV4, folders as connection points). Forms in steps: name and type,
  then the connection with its test (*Next* waits for it), then options or folders, each new
  folder tested before saving.
- **Canvas:** edited whole and saved in one transaction; configs with cron (UTC, with an ⓘ),
  object key placeholders, compression and enabled, starting with the workspace's defaults; Run
  now, a Test run of every flow, a guide for an empty workspace.
- **Backup engine:** cron scheduler; `pg_dump` → gzip → S3 multipart streamed without touching the
  disk; failed or cut uploads aborted; one run per config at a time, with its status, size, log and
  object key.
- **Backups and run log:** health summary, configs with last and next run, filters and sort, the
  next backup counting down by the second and reloading once due; the run log with filters and the
  detail of each run, its location, log and error selectable.
- **Quality of life:** a path per screen; warnings for long names and double compression; leaving
  an unsaved canvas asks first; a rail that expands from a notch; a splash, skeletons, Not found
  and Connection lost pages.
- **Checked:** restore guide (`docs/restore.md`), security model (`SECURITY.md`), end-to-end test
  in Docker, git history reviewed for secrets, every screen against the design, a manual test from
  scratch, and a code audit (18 findings) and a security audit (10 leads), all fixed.

Since `rc.8`:

- Service: Winter 1.0.0, its first stable version; deleting a workspace cancels the schedules of
  its backups at once; the route table is no longer logged at start.
- Console: the source and destination forms in steps, with the connection test next to its
  fields; an ⓘ by the cron of a config; the next backup counts down by the second and reloads once
  due; the splash of the design; it starts in the language of the browser when it is Spanish;
  locations, logs, errors and connection values can be selected and copied.
