# Roadmap

Dumpling backs up databases on a schedule and stores the dumps somewhere else. 0.1.0 has one source
(PostgreSQL) and one destination (S3), behind generic contracts: MySQL or MongoDB as sources and
Google Drive as a destination are a new implementation, not a change to the rest. What connects
them is the **canvas**: a source, a destination and the config between them, drawn and connected by
hand.

## 0.1.0

Built over the release candidates `0.1.0-rc.1` (2026-10-30) to `rc.8`; their changes, one by one,
are in the changelogs of [`service/`](service/CHANGELOG.md) and [`console/`](console/CHANGELOG.md).

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

## 0.2.0

- Benchmarks, with a script that repeats them and its results in the repo (like feather-io's): the
  memory of the service at rest, during a backup and after it, and how long a backup takes, by
  size of the database. Measured by hand on 0.1.0-rc.8 (the image, PostgreSQL 18 and feather-io,
  a 200 MB database): ~15 MiB at rest, ~100 MiB at the peak of a backup (the 16 MiB parts it
  uploads, plus ~11 MiB of `pg_dump`) and ~66 MiB minutes after it, memory Dart doesn't give back.
- Retention (needs ListObjects and DeleteObject in the destination).
- Destination detail with what is in the bucket (ListObjects): used space, objects, and the files,
  size and last write of each folder; and the history of its connection checks, not only the last.
- Source detail with the size of the database, the copies stored and the success rate of its
  runs; and the history of its connection checks, not only the last.
- `verify-full` with a CA for PostgreSQL sources (`require` and `disable` exist).
- Download a backup from the console.
- Events feed (changes, connection checks) and alerts.
- Live runs over a websocket: the service pushes each run's step, bytes and percentage as it goes,
  and the run log and its dialog update without Refresh. Until then a run in progress shows a
  generic bar and the bytes uploaded so far, and its log appears only when it ends. The same
  socket tells Backups when a scheduled run starts and ends and the next one is planned, so the
  countdown stays local and the screen updates without the reload it does once due (which stays,
  for a socket that is down). The token goes in its first message (a browser can't send headers on
  a WebSocket). To design in detail when it starts.
- Hardening left by the security audit: a new admin password ends the sessions already open;
  refuse to start with short secrets (today only a warning); pin the JWT algorithm and an
  audience; a retention for the run log; no redirects followed by the S3 client; the stored
  password dropped when a source's host changes; a `Content-Security-Policy` for the console.
- Copying connections between workspaces; zstd compression.
- More sources (MySQL, MariaDB, MongoDB) and destinations (Google Drive, SFTP, local download).

## Docker image

To weigh: publish the image, built by CI on each tag, so running Dumpling needs no clone and no
build. The `Dockerfile` at the root is already publishable (one image, no secrets in it, no
`VOLUME`); what is missing is the CI, the compose and the docs.

- **A release workflow** (`.github/workflows/release.yml`) on `push: tags: ['*.*.*']`, with
  `permissions: packages: write`: `docker/setup-qemu-action`, `setup-buildx-action`,
  `login-action` (ghcr.io with `GITHUB_TOKEN`), `metadata-action` (`type=semver,pattern={{version}}`:
  `latest` only on versions without `-rc`) and `build-push-action` with
  `platforms: linux/amd64,linux/arm64` and `cache-from/to: type=gha`. It runs the tests first
  (`needs:` a check job, or reuse `ci.yml`): a pushed tag publishes at once.
- **`docker-compose.yml` pulls it:** `image: ghcr.io/root-101/dumpling:<version>` instead of
  `build:`, so the compose and `.env.example` are all a user needs. The `build:` moves to a
  `docker-compose.override.yml` or stays in the README (`docker build`).
- **Docs:** "Run it" in the README starts with `docker run ghcr.io/...`.
- **The Railway template** deploys the published image instead of building the repo (the build
  takes minutes, the Flutter SDK included); its `PG_VERSION` variable goes away with the build.
- **Registry:** `ghcr.io` first (no extra secret, linked to the repo and its releases). Docker Hub
  is easier to find but needs a token as a secret and rate-limits anonymous pulls; both at once is
  a second login and a second line in `images:`.
- **`PG_VERSION`:** a build arg, so each published image carries one `pg_dump`. Publish with 18
  only: a newer `pg_dump` dumps older servers. Catch: a plain SQL dump of `pg_dump` 18 can carry
  statements (`SET transaction_timeout`) that fail when restored into an older server. Tags per
  version (`0.1.0-pg16`, a matrix) only if someone asks.
- **arm64:** QEMU is slow, worst on the Flutter web build. `FROM --platform=$BUILDPLATFORM
  debian:trixie-slim AS console` builds it once, natively (its output is JS, the same for every
  arch). The Dart stage does compile per arch: QEMU (slow, works), or `ubuntu-24.04-arm` runners
  (free on public repos) and a merged manifest. Start with QEMU.
- **Gotchas:** on ghcr.io the package is born private (make it public after the first push); the
  image name is lowercase (`root-101`, not `Root-101`).
- **Check first:** that `dart build cli` builds for arm64 under QEMU with the build hook of
  sqlite3, the likeliest to break: `docker buildx build --platform linux/arm64 .` locally, before
  writing the workflow.

## After 1.0

- Source metadata: the detail of a source shows what is in its database without reading any row:
  schemas, tables with their column count, estimated rows and size, and the types (enums,
  composites, domains). One more `SourceDriver` method each driver implements from its catalog
  (`pg_catalog` in PostgreSQL, `information_schema` in MySQL/MariaDB, `stats()` and a sample of
  documents in MongoDB, whose fields are only inferred). Row counts are estimates
  (`reltuples`, `TABLE_ROWS`, `estimatedDocumentCount`), never `count(*)`; what the user can't
  read shows as not available; the last result is kept with its time instead of querying on every
  visit.

## Random ideas

Loose ideas for possible improvements, not planned or weighed yet.

- Backup preview: a "Preview" on a backup shows what it holds without restoring it. The service
  downloads the file from the bucket, `pg_restore --list` gives the tree of schemas and tables,
  and picking a table shows its first rows, parsed from its `COPY` block
  (`pg_restore -a -t <table> -n <schema> -f -`). A plain SQL backup is already text. To check
  first: that the image carries `pg_restore` next to `pg_dump`, and the cost of downloading a big
  backup whole just to preview it.
