# Roadmap

Dumpling backs up databases on a schedule and stores the dumps somewhere else. 0.1.0 has one source
(PostgreSQL) and one destination (S3), behind generic contracts: MySQL or MongoDB as sources and
Google Drive as a destination are a new implementation, not a change to the rest. What connects
them is the **canvas**: a source, a destination and the config between them, drawn and connected by
hand.

## 0.1.0-rc.1 · Done

- **Foundations:** the service (Winter, drift + SQLite in WAL, slang, Problem Details) and the
  console (Flutter Web, flutter_bloc, go_router), both in English and Spanish. Credentials
  encrypted with AES-GCM and never returned. `SourceDriver` and `DestinationDriver` contracts with a
  registry of types, the disabled ones shown. CI with analyze and tests of both packages.
- **Release:** one image (the `Dockerfile` at the root) where the service serves the console;
  `pg_dump` of `PG_VERSION` from the PostgreSQL packages; `docker-compose.yml` with a volume and
  `.env.example`.
- **Auth:** one admin from the environment, a JWT of 12 h without refresh, failed logins limited
  per IP; a session that expires keeps the screen under a dialog that signs in again.
- **Workspaces:** create, edit, delete by typing the name (the files in the buckets stay); defaults
  for new configs; health stats on each card.
- **Sources:** PostgreSQL by fields or connection URL, custom or plain dumps, TLS by default; a
  test from the service that checks the server against the `pg_dump` of the image. MySQL, MariaDB,
  MongoDB and Redis listed as disabled.
- **Destinations:** S3-compatible with our own SigV4, optional folders as connection points, a
  test that starts and aborts a multipart upload. Google Drive, Azure Blob, Dropbox and SFTP listed
  as disabled.
- **Canvas:** edited whole and saved in one transaction; configs with cron (UTC), object key
  placeholders, compression and enabled; Run now, Test run of every flow, a guide for an empty
  workspace.
- **Backup engine:** cron scheduler; `pg_dump` → gzip → S3 multipart streamed without touching the
  disk; failed or cut uploads aborted; one run per config at a time, with its status, size, log and
  object key.
- **Backups and run log:** health summary, configs with last and next run, filters and sort; the
  run log with filters and the detail of each run; Not found and Connection lost pages.
- **Quality of life:** a path per screen; warnings for long names and double compression; leaving
  an unsaved canvas asks first; Save only with changes; logos of the types; dialogs in steps as tall
  as the screen; a rail that expands from a notch.
- **Before the release:** restore guide (`docs/restore.md`), security pass (`SECURITY.md`),
  end-to-end test in Docker, a review of the git history for secrets, every screen checked against
  the design, a manual test from scratch on 2026-10-27, and a code audit (18 findings) and a
  security audit (10 leads), all fixed.

## 0.1.0-rc.1 · Pending

- [x] Changelogs updated with the last changes of the console; README, `CONTRIBUTING.md` and
  `DECISIONS.md` reviewed.
- [x] End-to-end test (`service/tool/e2e/run.sh`) with the `Dockerfile` at the root: passed with
  MinIO on 2026-10-30.
- [x] A pass by hand over the last changes of the console: the rail and its notch, the dialogs in
  steps, the placeholders of the object key, the local time on the config nodes, the sign-in. On
  the image of the end-to-end test; fixed: the expanded Run log repeated its failing count.
- [x] Merge `feature/poc` into `main` and tag `0.1.0-rc.1`: released on 2026-10-30 as a
  [pre-release](https://github.com/Root-101/dumpling/releases/tag/0.1.0-rc.1).

## 0.1.0-rc.2

- [x] The README's wordmark readable on the light theme of GitHub, the repository public with its
  description and topics.

## 0.1.0-rc.3

- [x] A new version of the console shows on reload: its files are served with
  `Cache-Control: no-cache`, so the browser revalidates them instead of keeping the old build.

## 0.1.0-rc.4

- [x] The image deploys on Railway: the Dockerfile has no `VOLUME` (Railway rejects it); the
  volume is mounted where it runs (`-v`, compose or a Railway Volume on `/data`).

## 0.1.0-rc.5

- [x] The service opens its database on a Railway Volume: `/data` is given to `dumpling` when
  the container starts (Railway mounts it owned by root).

## 0.1.0-rc.6

- [x] A config created on the canvas starts with the schedule, compression and object key of the
  workspace: its dialog shows them instead of empty fields.

## 0.1.0-rc.7

- [x] A backup over TLS works in the image: the service runs with `HOME=/app`, so `pg_dump` no
  longer fails looking for a client certificate in `/root`.

## 0.2.0

- Retention (needs ListObjects and DeleteObject in the destination).
- Destination detail with what is in the bucket (ListObjects): used space, objects, and the files,
  size and last write of each folder; and the history of its connection checks, not only the last.
- Source detail with the size of the database, the copies stored and the success rate of its
  runs; and the history of its connection checks, not only the last.
- Source form: the connection test in step 2 (Connection), next to the fields it checks, instead
  of in step 3 (Check & save); the TLS setting, which the test uses, moves with it.
- Destination form: the same, the connection test in step 2 (Connection) instead of in step 3
  (Folders & check); it writes in each folder, so in step 2 it would test the root and step 3
  the folders.
- `verify-full` with a CA for PostgreSQL sources (`require` and `disable` exist).
- Download a backup from the console.
- Events feed (changes, connection checks) and alerts.
- Live runs over a websocket: the service pushes each run's step, bytes and percentage as it goes,
  and the run log and its dialog update without Refresh. Until then a run in progress shows a
  generic bar and the bytes uploaded so far, and its log appears only when it ends.
- Account screen; users and changing the password.
- Hardening left by the security audit: a new admin password ends the sessions already open;
  refuse to start with short secrets (today only a warning); pin the JWT algorithm and an
  audience; a retention for the run log; no redirects followed by the S3 client; the stored
  password dropped when a source's host changes; a `Content-Security-Policy` for the console.
- Copying connections between workspaces; zstd compression.
- More sources (MySQL, MariaDB, MongoDB) and destinations (Google Drive, SFTP, local download).
- To weigh: publish the image (Docker Hub or `ghcr.io`, amd64 and arm64), built by CI on each
  tag, with a `docker-compose.yml` that pulls it (`image:` instead of `build:`) and the
  `.env.example`, so running Dumpling needs no build. The secrets stay out of the image.

## After 1.0

- Source metadata: the detail of a source shows what is in its database without reading any row:
  schemas, tables with their column count, estimated rows and size, and the types (enums,
  composites, domains). One more `SourceDriver` method each driver implements from its catalog
  (`pg_catalog` in PostgreSQL, `information_schema` in MySQL/MariaDB, `stats()` and a sample of
  documents in MongoDB, whose fields are only inferred). Row counts are estimates
  (`reltuples`, `TABLE_ROWS`, `estimatedDocumentCount`), never `count(*)`; what the user can't
  read shows as not available; the last result is kept with its time instead of querying on every
  visit.
