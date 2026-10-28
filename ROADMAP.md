# Roadmap

The work up to **0.1.0-rc.1**, the first release candidate, in order. Mark each task with `[x]`
when it is done.

Dumpling backs up databases on a schedule and stores the dumps somewhere else. 0.1.0 has one source
(PostgreSQL) and one destination (S3), but both are generic from the start: MySQL or MongoDB as
sources and Google Drive as a destination must be a new implementation, not a change to the rest.
What connects them is the **canvas**: a source, a destination and the config between them are drawn
and connected by hand.

## Architecture

| Part      | Stack                                            | Notes                                                                                  |
|-----------|--------------------------------------------------|----------------------------------------------------------------------------------------|
| `service` | Winter, drift + SQLite, slang                    | Features organized like `feather-io/service/lib/features/admin/access_keys`            |
| `console` | Flutter Web, flutter_bloc, go_router, dio, slang | Same layers as feather-io's console (`data/`, `logic/`, `view/`)                       |
| Local run | Two processes, each one from its IDE run config  | The console points to the service with a `SERVICE_URL`                                 |
| Release   | One image, one server                            | The service serves the console build as static files (unlike feather-io's two servers) |

## Scope of 0.1.0

| In                                                                          | Out (0.2.0)                                       |
|-----------------------------------------------------------------------------|---------------------------------------------------|
| Workspaces, each with its own canvas, sources, destinations and configs     | Copying connections between workspaces            |
| Source PostgreSQL; MySQL, MariaDB, MongoDB, Redis shown but disabled        | Any other source working                          |
| Destination S3-compatible, its folders or the root; others disabled         | Google Drive, Azure, SFTP, local download working |
| One user from the env, JWT of 12 h, no refresh                              | Users, account screen, changing the password      |
| Schedules (cron, UTC) and manual runs                                       | Retention (only saving backups in 0.1.0)          |
| Run log per workspace, filtered by source type, destination type and status | Events feed (changes, connection checks), alerts  |
| Spanish and English in service and console                                  | Download a backup from the console, zstd          |

## M0 · Foundations

- [x] `service`: folders by feature like feather-io, `config/` from the env, i18n with slang
  (`es`, `en`), errors as Problem Details.
- [x] SQLite with drift (WAL) in a data folder: `workspace`, `source`, `destination`, `config`,
  `run` tables. Every time stored and sent in UTC.
- [x] Credentials (database passwords, S3 secret keys) encrypted with AES-GCM
  (`SECRETS_ENCRYPTION_KEY`, like feather-io's `SecretCipher`); the API never returns them.
- [x] Generic contracts: a `SourceDriver` (`testConnection`, `dump` as a byte stream) and a
  `DestinationDriver` (`testConnection`, `upload` from a stream). A registry of types with
  `enabled`, which the console reads to show the disabled ones.
- [x] Global rate limit per IP with Winter's `RateLimiterFilter` as the first filter (like
  feather-io).
- [x] `console`: i18n with slang (`es`, `en`) and a language switch, a `SERVICE_URL` for the local
  run, a base client with the token. Times shown in UTC, with the local time smaller next to them.
- [x] Release: one Dockerfile that builds the console and serves it from the service;
  `docker-compose.yml` with a volume; `.env.example`.
- [x] `pg_dump` from the official PostgreSQL packages, its major version from `PG_VERSION` in the
  `.env` (a build arg: changing it and running `docker compose up -d --build` updates it). The
  service reads `pg_dump --version` (`PG_DUMP_PATH`) for the compatibility check; the image is
  what is missing.
- [x] CI: analyze and tests of both packages (`.github/workflows/ci.yml`), on every push to
  `develop` or `main`.

## M1 · Auth

Screens: Login, Login · Wrong password, Error · Session expired.

- [x] `DUMPLING_ADMIN_USER`, `DUMPLING_ADMIN_PASSWORD` and `JWT_SECRET` from the env, without defaults.
- [x] `POST /api/auth/login` returns a JWT of 12 h; every other `/api` route requires it.
- [x] Failed logins limited per IP like feather-io's `LoginRateLimiter` (delay per failure, lock
  after several in a row).
- [x] Console: login screen (a wrong password shows the error of the service inside the form);
  a `401` sends back to the login, there is no refresh; back to the page asked for after signing
  in; sign out.
- [ ] Console: the Error · Session expired screen of the design (today a `401` goes straight to
  the login).

## M2 · Workspaces

Screens: Workspaces, Workspaces · New workspace, Workspace settings, Workspace settings · Delete.

- [x] CRUD: name, description and color.
- [x] Defaults for new configs: schedule, compression, object key.
- [x] Delete by typing its name: its sources, destinations, configs and runs go, the files in the
  buckets stay.
- [x] `GET /api/workspaces` returns the `stats` of each workspace: sources, destinations,
  configs, failing, running and the last run.
- [x] Console: list, switch, create, settings, delete. List (cards with counts, health and last
  run), switch (the rail, by the URL, the last one remembered), create, and settings (a dialog
  from the card: general, defaults, delete) are done.

## M3 · Sources

Screens: Sources · List / New source / Row options / Delete confirmation, Source detail.

- [x] Type list with PostgreSQL enabled and MySQL, MariaDB, MongoDB and Redis disabled.
- [x] PostgreSQL by fields or by connection URL (the service parses it; a field given apart wins);
  dump format plain SQL or custom (`-Fc`). Always without SSL: no `ssl_mode` in the API yet.
- [x] `POST /api/workspaces/{slug}/sources/test` with the data of the form (before saving) and
  `POST /api/workspaces/{slug}/sources/{id}/test` (saved): the service connects, never the console, so the database
  can be in its internal network.
- [x] The test reads `server_version_num` and compares it with the `pg_dump` of the image: a server
  newer than `pg_dump` is reported as not compatible. Checked again before every run.
- [x] List, detail, edit, delete only when no config uses it (the console searches and filters the
  list).
- [x] Console: list (rows or cards) with search and type filter, create (by fields or URL) and
  edit (an empty password keeps the saved one) in a dialog in steps, duplicate, test, delete only
  when no backup uses it, and the detail in a dialog: the backups that dump it (schedule, last
  and next run), the last check, the connection.

## M4 · Destinations

Screens: Destinations · List / New destination / Row options / Delete confirmation, Destination detail.

- [x] Type list with S3 enabled and Google Drive, Azure Blob, Dropbox and SFTP disabled.
- [x] S3: endpoint, region, keys, path-style addressing and bucket: what the connection needs.
- [x] Optional folders in the bucket: with at least one, each folder is a connection point on the
  canvas and the root is not; with none, the root is the only one. The object keys of the configs
  are relative to the folder they write to.
- [x] S3 client: our own SigV4 signing (from feather-io's `SigV4Signer`): `minio` can't abort an
  upload by its id, so a failed one would stay. Only PutObject and multipart.
- [x] Test from the service, like sources, leaving nothing in the bucket: start a multipart upload
  in each folder (or the root) and abort it, which proves the credentials, the bucket and the
  write permission there.
- [x] List, detail, edit, delete only when no config writes to it.
- [x] Console: list (rows or cards) with search and type filter, create and edit in a dialog in
  steps, duplicate, test, delete, the folders of each bucket added or deleted from its row, and
  the detail in a dialog: the backups that write to each folder, the last check, the connection.

## M5 · Canvas

Screens: Pipeline editor, Getting started · Empty workspace.

- [x] The canvas of 0.0.1 is edited whole in the console and saved with one Save: sources,
  destinations, configs, their connections and positions, in one transaction.
  `GET /api/workspaces/{slug}/canvas` loads it and `PUT` saves it. What the save leaves out is
  deleted; new nodes have an id the console makes up (`new_…`), and the response maps it to the
  saved one. A source or destination without position is off the canvas (in the toolbar, and
  "Remove from canvas" sends it back there: it is not deleted). A folder can be added to a bucket
  from the canvas too; with the first one, the configs on the root are disconnected.
- [x] Config between a source and a destination: name, schedule (cron in UTC), object key with
  placeholders (`{yyyy}`, `{MM}`, `{dd}`, `{HH}`, `{mm}`, `{db}`, `{run_id}`) and without
  extension, compression (gzip or none), enabled. The engine adds the extension from the dump
  format and the compression. The panel checks each field like the service does, and a save it
  rejects says which config and why.
- [x] Only complete flows are saved (as today in 0.0.1): the console leaves out the orphan
  configs, which the service would reject.
- [x] Run now from the config: a real run of the saved config (a new one is saved first),
  followed until it ends; its node shows it and a notice says the size or the error.
- [x] Test run from the header: checks without backing anything up that every complete flow
  could run (each source connects and `pg_dump` can dump it, each destination takes a write in
  its folders, the ones added on the canvas and not saved yet too).
- [x] Empty workspace guide: add a source, add a destination, connect them. Until the first
  config; a step places what is off the canvas, or goes to create it when there is none.

## M6 · Backup engine

- [x] The scheduler runs the enabled configs (Winter's cron in UTC) and reloads them when they
  change.
- [x] A run streams from end to end: `pg_dump` to stdout → gzip → parts of 16 MiB → S3 multipart
  upload (a single PutObject when it fits in one part). The dump never touches the disk and the
  memory stays at a few parts.
- [x] A failed run aborts its multipart upload, so no half file remains in the bucket.
- [x] Each run stores status, trigger (schedule or manual), size, duration, log lines and the
  object key it wrote.
- [x] One run per config at a time; runs left half-done by a restart are marked failed.

## M7 · Backups and run log

Screens: Backups, Backups · Filters / Sort / Run details, Events (as the run log), Events · Filters.

- [x] Backups: summary (healthy, failing, next run), configs with their last and next run, filters
  and sort. The service side is done: each config has `next_run` and `last_run`.
- [x] Run log per workspace: every run, newest first, filtered by source type, destination type
  and status. The service side is done (the 200 newest; paging when it is needed).
- [x] Run detail: steps, log (copy). The service side is done.
- [x] Error states: Error · Not found, Error · Connection lost.

## M8 · Release candidate

- [x] Restore guide: `pg_restore` / `psql` of a file taken from the bucket.
- [x] Security pass (`SECURITY.md`): credentials, auth, rate limits, input validation, what the
  logs show.
- [x] End-to-end test with PostgreSQL and MinIO (or feather-io) in Docker.
- [ ] README, `CONTRIBUTING.md`, `DECISIONS.md`, changelogs; versions and tag `0.1.0-rc.1`.

## Quality of life

UX/UI improvements in 0.1.0, not features.

- [ ] Long names: sources, destinations and configs each have a name. When it is longer than a
  limit (one console constant, about 10 characters, to tune on the canvas), a small warning under
  the field says to choose a shorter name so it reads well on the canvas. It does not block saving.
- [ ] Double compression: a PostgreSQL source with the custom format (`pg_dump -Fc`, already
  compressed) and a config with gzip is allowed and compressed twice, but a small warning under
  the compression field says it barely makes the file smaller.
- [ ] Navigable URLs: every screen has its own path, so it can be bookmarked, shared, reloaded and
  reached with the browser's back and forward: `/workspaces`, `/workspaces/{slug}/canvas`,
  `/workspaces/{slug}/backups`, `/workspaces/{slug}/backups/runs/{id}`,
  `/workspaces/{slug}/sources/{id}`, `/workspaces/{slug}/destinations/{id}`,
  `/workspaces/{slug}/runs` (with its filters in the query), `/workspaces/{slug}/settings`. The
  slug comes from the workspace name when it is created (`test-workspace`), is unique and doesn't
  change on a rename, so links keep working. An unknown path or slug shows Error · Not found.
  Done: `/workspaces` and `/workspaces/{slug}/{section}`, reloaded or opened from a link (without
  a session, the login opens it after signing in). Missing: the paths of the details and of a run,
  and Error · Not found.
- [ ] Unsaved canvas: leaving the canvas (another screen, another workspace, closing or reloading
  the tab) with changes not saved asks first that they will be discarded.
- [ ] Save only with changes: the Save button of the canvas is disabled until something changes,
  and again once saved (or once the changes are undone).

## Design changes

Applied on the canvas on 2026-10-25:

- [x] Sources: remove S3 as a source.
- [x] Account: move to a separate "Later (0.2.0)" section.
- [x] Settings: no retention, no time zone.
- [x] Events: becomes the run log (filters by source type, destination type, status).
- [x] Times: UTC first, local time smaller.
- [x] Backups: no download, no retention step.

## Manual test from scratch · 2026-10-27

The whole app by hand, on a new database: the service on `localhost:8180` with an empty
`DATA_PATH`, the console built and served on `localhost:8181`, PostgreSQL and an S3 server in
Docker. Each step is checked once it works in Chrome; what fails is noted under it.

- [x] Console: analyze and every test (73).
- [x] Service: analyze and every test (95). The preview test expected 2 configs where the
  workspace of the test has more: it checks the cap of 3 now.
- [x] PostgreSQL (seeded `shop` database) and S3 (a bucket) in Docker.
- [x] Service and console up, on an empty database.
- [x] Login: wrong password, then the right one.
- [x] Workspaces: empty list, then a new workspace (name, description, color).
  - Fixed: once created it stayed on the list. Every notice shown with `app.context` (the root
    Navigator) failed looking for an overlay above it, before navigating; the notice takes the
    root Navigator's overlay now. A test creates a workspace and expects its backups.
  - Fixed: "No backups yet" was cut on the card; the label keeps its width.
- [x] Sources: a new PostgreSQL source in steps, its connection test, its detail.
  - Fixed: a source tested in the form showed "Not tested" once created (the test of the form
    ran before it existed); a form saved as it was tested tests it again once saved.
- [x] Destinations: a new S3 destination with a folder, its connection test, its detail. The
  same fix as the sources for "Not tested" once created.
- [x] Canvas: both on the canvas, a config between them, saved. Its notice did not show (the
  same fix as the workspaces).
- [x] Config: edited in its dialog (schedule, object key, compression).
- [x] Run now: a success in 1 s, with its steps and log; the file is in the bucket
  (`shop/shop/2026-10-27-run_….dump`, 147 KB) and `pg_restore --list` reads both tables. The run
  was too short to see it in progress.
- [x] A failing run: a source with a wrong password (its test says why), the failure in Backups
  (Failed, the error under the date, 1 failing in the summary).
  - Fixed: the config of a second source on the same folder landed on top of the first config
    on the canvas; it goes below the configs it would cover now.
- [x] Backups: summary, filters (status), sort (source name), recent runs of a backup and the
  run details from them.
- [x] Run log: the runs by day, search, filters (status), "Nothing matches" and clearing them,
  a failed run's detail (the failed step, the skipped one, the log).
  - Fixed: inside the workspace the rail showed no failing badge after the failed run (its
    count comes from the list of workspaces); a run that ends in Backups or the canvas reloads
    the list. A scheduled run still shows once the list loads again.
- [x] Workspace card: the preview of its configs (2 sources, 2 configs with the failing one in
  red, 1 destination), its counts and health, the settings button. Back on the list, the rail
  shows the failing badge.
- [x] Workspace settings: General (read, edit: description and color, the header follows as it
  is typed), defaults saved (weekly, no compression; the API returns them), delete asks for the
  name and keeps its button off until it matches.
  - Fixed: "1 destinations" in the delete confirmation; the counts go in parentheses now.
  - Fixed: the footer lost height on the tabs without *Edit*; it has a fixed height.
- [x] Deleting the workspace: gone from the list, and from the database its sources,
  destinations, folders, configs and runs; the file in the bucket stays.

## 0.2.0

- Retention (needs ListObjects and DeleteObject in the destination).
- Destination detail with what is in the bucket (ListObjects): used space, objects, and the files,
  size and last write of each folder; and the history of its connection checks, not only the last.
- Source detail with the size of the database, the copies stored and the success rate of its
  runs; and the history of its connection checks, not only the last.
- SSL for PostgreSQL sources: `ssl_mode` in the API and the console (`require`; `verify-full`
  with a CA).
- Download a backup from the console.
- Events feed (changes, connection checks) and alerts.
- Live runs over a websocket: the service pushes each run's step, bytes and percentage as it goes,
  and the run log and its dialog update without Refresh. Until then a run in progress shows a
  generic bar and the bytes uploaded so far, and its log appears only when it ends.
- Account screen; users and changing the password.
- Copying connections between workspaces; zstd compression.
- More sources (MySQL, MariaDB, MongoDB) and destinations (Google Drive, SFTP, local download).

## After 1.0

- Source metadata: the detail of a source shows what is in its database without reading any row:
  schemas, tables with their column count, estimated rows and size, and the types (enums,
  composites, domains). One more `SourceDriver` method each driver implements from its catalog
  (`pg_catalog` in PostgreSQL, `information_schema` in MySQL/MariaDB, `stats()` and a sample of
  documents in MongoDB, whose fields are only inferred). Row counts are estimates
  (`reltuples`, `TABLE_ROWS`, `estimatedDocumentCount`), never `count(*)`; what the user can't
  read shows as not available; the last result is kept with its time instead of querying on every
  visit.
